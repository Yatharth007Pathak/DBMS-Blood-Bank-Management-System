const API = "http://localhost:5000/api";

async function fetchInventory() {
  try {
    const res = await fetch(`${API}/inventory`);
    return await res.json();
  } catch (err) {
    console.error("Error fetching inventory:", err);
    return [];
  }
}

async function renderInventory() {
  const tbody = document.querySelector("#inventory-table tbody");
  if (!tbody) return; // Not on inventory page

  const data = await fetchInventory();
  tbody.innerHTML = data
    .map(
      (r) => `
        <tr>
          <td>${r.unit_id}</td>
          <td>${r.blood_group}</td>
          <td>${r.donor_id || "-"}</td>
          <td>${r.quantity_ml}</td>
          <td>${r.blood_component}</td>
          <td>${r.donation_date || "-"}</td>
          <td>${r.expiry_date || "-"}</td>
          <td>${r.storage_location || "-"}</td>
          <td>${r.storage_temperature || "-"}</td>
          <td>${r.status}</td>
          <td>${r.remarks || "-"}</td>
          <td>${r.updated_at ? new Date(r.updated_at).toLocaleString("en-CA") : "-"}</td>
        </tr>`
    )
    .join("");
}

const stockForm = document.getElementById("stock-form");
if (stockForm) {
  stockForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const f = new FormData(stockForm);
    const payload = {
      blood_group: f.get("blood_group"),
      donor_id: Number(f.get("donor_id")),
      quantity_ml: Number(f.get("quantity_ml")),
      blood_component: f.get("blood_component"),
      donation_date: f.get("donation_date"),
      storage_location: f.get("storage_location"),
      storage_temperature: Number(f.get("storage_temperature")),
      status: f.get("status"),
      remarks: f.get("remarks"),
    };

    try {
      const res = await fetch(`${API}/inventory`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      if (!res.ok) throw new Error("Failed to add blood unit");
      alert("✅ Inventory updated successfully!");
      await renderInventory();
      stockForm.reset();
    } catch (err) {
      alert("❌ Error updating inventory: " + err.message);
      console.error(err);
    }
  });
}

async function renderDonors() {
  const tbody = document.querySelector("#donors-table tbody");
  if (!tbody) return;

  try {
    const res = await fetch(`${API}/donors`);
    const donors = await res.json();

    tbody.innerHTML = donors
      .map((d) => {
        const genderLabel =
          d.gender === "M" ? "Male" : d.gender === "F" ? "Female" : "Other";
        const lastDonation =
          d.last_donation && d.last_donation !== "null"
            ? new Date(d.last_donation).toLocaleDateString("en-CA")
            : "-";
        const created =
          d.created_at && d.created_at !== "null"
            ? new Date(d.created_at).toLocaleDateString("en-CA")
            : "-";
        return `
        <tr>
          <td>${d.donor_id}</td>
          <td>${d.name}</td>
          <td>${genderLabel}</td>
          <td>${d.age}</td>
          <td>${d.blood_group}</td>
          <td>${d.phone || "-"}</td>
          <td>${d.email || "-"}</td>
          <td>${d.city || "-"}</td>
          <td>${lastDonation}</td>
          <td>${created}</td>
          <td><button class="set-donation" data-id="${d.donor_id}">Set Today</button></td>
        </tr>`;
      })
      .join("");

    // Event: Update last donation date
    document.querySelectorAll(".set-donation").forEach((btn) => {
      btn.addEventListener("click", async () => {
        const id = btn.dataset.id;
        const today = new Date().toISOString().split("T")[0];
        try {
          const res = await fetch(`${API}/donors/${id}/last_donation`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ last_donation: today }),
          });
          if (!res.ok) throw new Error("Failed to update");
          alert("✅ Last donation updated!");
          await renderDonors();
        } catch (err) {
          console.error("Error updating donation date:", err);
          alert("❌ " + err.message);
        }
      });
    });
  } catch (err) {
    console.error("Error loading donors:", err);
  }
}

const donorForm = document.getElementById("donor-form");
if (donorForm) {
  donorForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const f = new FormData(donorForm);
    const payload = {
      name: f.get("name"),
      gender: f.get("gender"),
      age: Number(f.get("age")),
      blood_group: f.get("blood_group"),
      phone: f.get("phone"),
      email: f.get("email"),
      city: f.get("city"),
      last_donation: f.get("last_donation"),
    };

    try {
      const res = await fetch(`${API}/donors`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      if (!res.ok) throw new Error("Failed to register donor");
      alert("✅ Donor registered successfully!");
      donorForm.reset();
      await renderDonors();
    } catch (err) {
      console.error("Error registering donor:", err);
      alert("❌ " + err.message);
    }
  });
}

async function renderRequests() {
  const tbody = document.querySelector("#requests-table tbody");
  if (!tbody) return;

  try {
    const res = await fetch(`${API}/requests`);
    const requests = await res.json();

    tbody.innerHTML = requests
      .map(
        (r) => `
      <tr>
        <td>${r.request_id}</td>
        <td>${r.patient_name}</td>
        <td>${r.hospital || "-"}</td>
        <td>${r.blood_group}</td>
        <td>${r.units_requested}</td>
        <td>${r.request_reason || "-"}</td>
        <td>${r.status}</td>
        <td>${r.requested_at ? new Date(r.requested_at).toLocaleString("en-CA") : "-"}</td>
        <td>${r.fulfilled_at ? new Date(r.fulfilled_at).toLocaleString("en-CA") : "-"}</td>
        <td>
          ${
            r.status === "PENDING"
              ? `<button class="fulfill" data-id="${r.request_id}">Fulfill</button>`
              : "-"
          }
        </td>
      </tr>`
      )
      .join("");

    // Fulfill button action
    document.querySelectorAll(".fulfill").forEach((btn) => {
      btn.addEventListener("click", async () => {
        const id = btn.dataset.id;
        try {
          const res = await fetch(`${API}/requests/${id}/fulfill`, { method: "POST" });
          if (!res.ok) throw new Error("Failed to fulfill request");
          alert("✅ Request fulfilled!");
          await renderRequests();
          await renderInventory();
        } catch (err) {
          console.error("Error fulfilling request:", err);
          alert("❌ " + err.message);
        }
      });
    });
  } catch (err) {
    console.error("Error rendering requests:", err);
  }
}

const requestForm = document.getElementById("request-form");
if (requestForm) {
  requestForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const f = new FormData(requestForm);
    const payload = {
      patient_name: f.get("patient_name"),
      hospital: f.get("hospital"),
      blood_group: f.get("blood_group"),
      units_requested: Number(f.get("units_requested")),
      request_reason: f.get("request_reason"),
      status: f.get("status") || "PENDING",
    };

    try {
      const res = await fetch(`${API}/requests`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      if (!res.ok) throw new Error("Failed to create request");
      alert("✅ Request created successfully!");
      requestForm.reset();
      await renderRequests();
    } catch (err) {
      console.error("Error submitting request:", err);
      alert("❌ " + err.message);
    }
  });
}

window.addEventListener("DOMContentLoaded", async () => {
  await renderInventory();
  await renderDonors();
  await renderRequests();
});
