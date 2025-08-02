// Helper function to filter RFQs table
window.filterRFQs = function(filteredRfqs) {
  const table = document.getElementById('rfqs-table');
  const tbody = table.querySelector('tbody');
  
  if (!tbody) return;
  
  // Get all rows
  const rows = tbody.querySelectorAll('tr');
  
  // Hide all rows first
  rows.forEach(row => {
    row.style.display = 'none';
  });
  
  // Show only filtered rows
  filteredRfqs.forEach(rfq => {
    const row = tbody.querySelector(`tr[data-rfq-id="${rfq.id}"]`);
    if (row) {
      row.style.display = '';
    }
  });
  
  // Update results count
  const visibleCount = filteredRfqs.length;
  const totalCount = rows.length;
  
  // Add or update results summary
  let summary = document.getElementById('filter-summary');
  if (!summary) {
    summary = document.createElement('div');
    summary.id = 'filter-summary';
    summary.className = 'px-6 py-3 bg-gray-50 text-sm text-gray-600';
    table.insertBefore(summary, table.firstChild);
  }
  
  if (visibleCount < totalCount) {
    summary.textContent = `Showing ${visibleCount} of ${totalCount} RFQs`;
  } else {
    summary.textContent = `Showing all ${totalCount} RFQs`;
  }
};