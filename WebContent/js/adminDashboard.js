/*********************************
 * SIDEBAR NAVIGATION FIX
 *********************************/
function showSection(sectionId) {
    // Hide all sections
    var sections = document.querySelectorAll(".content-section");
    for (var i = 0; i < sections.length; i++) {
        sections[i].style.display = "none";
    }

    // Show selected section
    var activeSection = document.getElementById(sectionId);
    if (activeSection) {
        activeSection.style.display = "block";
    }
}

function toggleMenu(menuId) {
    var menu = document.getElementById(menuId);
    if (!menu) return;

    if (menu.style.display === "block") {
        menu.style.display = "none";
    } else {
        menu.style.display = "block";
    }
}



/*********************************
 * GLOBAL STATE
 *********************************/
var tableState = {};

/*********************************
 * PAGE LOAD
 *********************************/
document.addEventListener("DOMContentLoaded", function () {
    initAllTables();
});

/*********************************
 * INIT TABLES
 *********************************/
function initAllTables() {
    var types = ["admin", "teacher", "student", "all-users"];

    for (var t = 0; t < types.length; t++) {
        initTable(types[t]);
    }
}

function initTable(type) {
    var tbody = document.getElementById(type + "TableBody");
    if (!tbody) return;

    var rows = Array.prototype.slice.call(tbody.querySelectorAll("tr"));

    tableState[type] = {
        allRows: rows,
        filteredRows: rows,
        page: 1,
        pageSize: 10
    };

    renderTable(type);
}

/*********************************
 * FILTER
 *********************************/
function filterTable(type) {
    var state = tableState[type];
    if (!state) return;

    var searchBox = document.getElementById(type + "Search");
    var roleBox = document.getElementById(type + "RoleFilter");
    var statusBox = document.getElementById(type + "StatusFilter");

    var search = searchBox ? searchBox.value.toLowerCase() : "";
    var role = roleBox ? roleBox.value : "all";
    var status = statusBox ? statusBox.value : "all";

    state.filteredRows = state.allRows.filter(function (row) {
        var text = row.innerText.toLowerCase();
        var rowRole = row.getAttribute("data-role");
        var rowStatus = row.getAttribute("data-status");

        if (search && text.indexOf(search) === -1) return false;
        if (role !== "all" && rowRole !== role) return false;
        if (status !== "all" && rowStatus !== status) return false;

        return true;
    });

    state.page = 1;
    renderTable(type);
}

/*********************************
 * RENDER TABLE
 *********************************/
function renderTable(type) {
    var state = tableState[type];
    var tbody = document.getElementById(type + "TableBody");

    for (var i = 0; i < state.allRows.length; i++) {
        state.allRows[i].style.display = "none";
    }

    var start = (state.page - 1) * state.pageSize;
    var end = start + state.pageSize;

    for (var j = start; j < end && j < state.filteredRows.length; j++) {
        state.filteredRows[j].style.display = "";
    }

    updateCounts(type);
    buildPagination(type);
}

/*********************************
 * COUNTS
 *********************************/
function updateCounts(type) {
    var state = tableState[type];

    var showEl = document.getElementById(type + "ShowingCount");
    var totalEl = document.getElementById(type + "TotalCount");

    if (showEl) {
        showEl.innerText = Math.min(state.pageSize, state.filteredRows.length);
    }
    if (totalEl) {
        totalEl.innerText = state.filteredRows.length;
    }
}

/*********************************
 * PAGINATION (NO ${})
 *********************************/
function buildPagination(type) {
    var state = tableState[type];
    var pager = document.getElementById(type + "Pagination");
    if (!pager) return;

    var totalPages = Math.ceil(state.filteredRows.length / state.pageSize);
    var ul = pager.querySelector("ul");
    ul.innerHTML = "";

    for (var i = 1; i <= totalPages; i++) {
        var li = document.createElement("li");
        li.className = "page-item" + (i === state.page ? " active" : "");

        var a = document.createElement("a");
        a.className = "page-link";
        a.href = "#";
        a.innerText = i;
        a.onclick = (function (p) {
            return function () {
                changePage(type, p);
            };
        })(i);

        li.appendChild(a);
        ul.appendChild(li);
    }
}

function changePage(type, page) {
    tableState[type].page = page;
    renderTable(type);
}

/*********************************
 * EXPORT (FIXED)
 *********************************/
function exportToExcel(type) {
    var state = tableState[type];
    if (!state || state.filteredRows.length === 0) {
        alert("No data to export");
        return;
    }

    var csv = "";
    var table = document.getElementById(type + "TableBody").closest("table");
    var headers = table.querySelectorAll("thead th");

    for (var h = 0; h < headers.length - 1; h++) {
        csv += headers[h].innerText + ",";
    }
    csv += "\n";

    for (var r = 0; r < state.filteredRows.length; r++) {
        var cells = state.filteredRows[r].querySelectorAll("td");
        for (var c = 0; c < cells.length - 1; c++) {
            csv += '"' + cells[c].innerText.replace(/"/g, '""') + '",';
        }
        csv += "\n";
    }

    var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
    var link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = type + "_users.csv";
    link.click();
}

/*********************************
 * CRUD
 *********************************/
function deleteUser(id) {
    if (!confirm("Delete user?")) return;

    var data = new URLSearchParams();
    data.append("action", "delete");
    data.append("id", id);

    fetch("UserServlet", { method: "POST", body: data })
        .then(function (r) { return r.json(); })
        .then(function (res) {
            if (res.success) location.reload();
            else alert(res.message);
        });
}
