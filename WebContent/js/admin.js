
var currentUserId = null;
var tableState = {
 'admin': { currentPage: 1, pageSize: 10, filteredRows: [], totalRows: 0, searchTerm: '', statusFilter: 'all', sortBy: 'id' },
 'teacher': { currentPage: 1, pageSize: 10, filteredRows: [], totalRows: 0, searchTerm: '', statusFilter: 'all', deptFilter: 'all', sortBy: 'id' },
 'student': { currentPage: 1, pageSize: 10, filteredRows: [], totalRows: 0, searchTerm: '', statusFilter: 'all', deptFilter: 'all', classFilter: 'all', sortBy: 'id' },
 'all-users': { currentPage: 1, pageSize: 10, filteredRows: [], totalRows: 0, searchTerm: '', roleFilter: 'all', statusFilter: 'all', sortBy: 'id' }
};

document.addEventListener('DOMContentLoaded', function() {
 initializeAll();
});

function initializeAll() {
 initializeTable('admin');
 initializeTable('teacher');
 initializeTable('student');
 initializeTable('all-users');
 showSection('dashboard');
 setupFormHandlers();
 setupMobileMenu();
 adjustNavigationForMobile();
 window.addEventListener('resize', adjustNavigationForMobile);
}

function setupFormHandlers() {
 document.getElementById('addUserForm').addEventListener('submit', function(e) {
     e.preventDefault();
     addUser();
 });
 
 document.getElementById('editUserForm').addEventListener('submit', function(e) {
     e.preventDefault();
     updateUser();
 });
 
 document.getElementById('editIsActive').addEventListener('change', function() {
     document.getElementById('statusText').textContent = this.checked ? 'Active' : 'Inactive';
 });
}

function setupMobileMenu() {
 var menuToggle = document.getElementById('menuToggle');
 var sidebar = document.querySelector('.sidebar');
 
 if (menuToggle && sidebar) {
     menuToggle.addEventListener('click', function(e) {
         e.stopPropagation();
         sidebar.classList.toggle('active');
     });
     
     document.addEventListener('click', function(event) {
         if (window.innerWidth <= 992 && sidebar.classList.contains('active') && 
             !sidebar.contains(event.target) && !menuToggle.contains(event.target)) {
             sidebar.classList.remove('active');
         }
     });
 }
}

function initializeTable(tableType) {
 var tableBody = document.getElementById(tableType + 'TableBody');
 if (!tableBody) return;
 
 var rows = [];
 var allRows = tableBody.querySelectorAll('tr');
 for (var i = 0; i < allRows.length; i++) {
     rows.push(allRows[i]);
 }
 
 tableState[tableType].totalRows = rows.length;
 tableState[tableType].filteredRows = rows;
 filterTable(tableType);
}

function addUser() {
 var form = document.getElementById("addUserForm");
 var formData = new FormData(form);
 
 var username = formData.get('username');
 var password = formData.get('password');
 var email = formData.get('email');
 var fullName = formData.get('fullName');
 var role = formData.get('role');
 
 if (!username || !password || !email || !fullName || !role) {
     Swal.fire("Validation Error", "Please fill all required fields", "warning");
     return;
 }
 
 if (password.length < 6) {
     Swal.fire("Validation Error", "Password must be at least 6 characters", "warning");
     return;
 }
 
 var isActiveCheckbox = document.querySelector('#addUserForm input[name="isActive"]');
 formData.set('isActive', isActiveCheckbox && isActiveCheckbox.checked ? 'true' : 'false');
 
 var data = new URLSearchParams(formData);
 data.append("action", "add");
 
 Swal.fire({
     title: 'Adding User...',
     allowOutsideClick: false,
     didOpen: function() { Swal.showLoading(); }
 });

 fetch("UserServlet", {
     method: "POST",
     headers: { "Content-Type": "application/x-www-form-urlencoded" },
     body: data.toString()
 })
 .then(function(res) { return res.json(); })
 .then(function(result) {
     Swal.close();
     if (result.success) {
         Swal.fire({ icon: "success", title: "Success!", text: result.message, timer: 2000 })
             .then(function() { location.reload(); });
     } else {
         Swal.fire("Error", result.message, "error");
     }
 })
 .catch(function(err) {
     console.error("Add User Error:", err);
     Swal.close();
     Swal.fire("Error", "Failed to add user", "error");
 });
}

function viewUser(id) {
 currentUserId = id;
 var modal = new bootstrap.Modal(document.getElementById('viewUserModal'));
 document.getElementById('viewUserLoading').style.display = 'block';
 document.getElementById('userDetailsContent').style.display = 'none';
 modal.show();
 
 fetch("UserServlet?action=getUser&id=" + id)
 .then(function(res) { return res.json(); })
 .then(function(user) {
     document.getElementById('viewUserLoading').style.display = 'none';
     document.getElementById('userDetailsContent').style.display = 'block';
     
     var roleClass = user.role === 'admin' ? 'badge-admin' : (user.role === 'teacher' ? 'badge-teacher' : 'badge-student');
     var html = '<div class="text-center mb-4"><div class="user-avatar-large">' + user.fullName.charAt(0).toUpperCase() + '</div>' +
         '<h4 class="mb-1">' + user.fullName + '</h4><span class="badge ' + roleClass + '">' + user.role.toUpperCase() + '</span></div>' +
         '<div class="row"><div class="col-md-6">' +
         '<div class="detail-row"><div class="detail-label"><i class="fas fa-id-badge me-2"></i>User ID</div><div class="detail-value">' + user.id + '</div></div>' +
         '<div class="detail-row"><div class="detail-label"><i class="fas fa-user me-2"></i>Username</div><div class="detail-value">' + user.username + '</div></div>' +
         '<div class="detail-row"><div class="detail-label"><i class="fas fa-envelope me-2"></i>Email</div><div class="detail-value">' + user.email + '</div></div>' +
         '<div class="detail-row"><div class="detail-label"><i class="fas fa-phone me-2"></i>Phone</div><div class="detail-value">' + (user.phone || 'N/A') + '</div></div></div>' +
         '<div class="col-md-6"><div class="detail-row"><div class="detail-label"><i class="fas fa-building me-2"></i>Department</div><div class="detail-value">' + (user.department || 'N/A') + '</div></div>';
     
     if (user.role === 'teacher') {
         html += '<div class="detail-row"><div class="detail-label"><i class="fas fa-book me-2"></i>Subjects</div><div class="detail-value">' + (user.subjects || 'N/A') + '</div></div>';
     }
     if (user.role === 'student') {
         html += '<div class="detail-row"><div class="detail-label"><i class="fas fa-id-card me-2"></i>Roll Number</div><div class="detail-value">' + (user.rollNo || 'N/A') + '</div></div>' +
             '<div class="detail-row"><div class="detail-label"><i class="fas fa-users me-2"></i>Class</div><div class="detail-value">' + (user.className || 'N/A') + '</div></div>';
     }
     
     html += '<div class="detail-row"><div class="detail-label"><i class="fas fa-toggle-on me-2"></i>Status</div><div class="detail-value">' +
         '<span class="badge ' + (user.active ? 'bg-success' : 'bg-danger') + '">' + (user.active ? 'Active' : 'Inactive') + '</span></div></div></div></div>';
     
     document.getElementById('userDetailsContent').innerHTML = html;
 })
 .catch(function(err) {
     console.error("View User Error:", err);
     Swal.fire("Error", "Failed to load user details", "error");
     modal.hide();
 });
}

function editUser(id) {
 currentUserId = id;
 var modal = new bootstrap.Modal(document.getElementById('editUserModal'));
 
 fetch("UserServlet?action=getUser&id=" + id)
 .then(function(res) { return res.json(); })
 .then(function(user) {
     document.getElementById('editUserId').value = user.id;
     document.getElementById('editUserRole').value = user.role;
     document.getElementById('editFullName').value = user.fullName;
     document.getElementById('editUsername').value = user.username;
     document.getElementById('editEmail').value = user.email;
     document.getElementById('editPhone').value = user.phone || '';
     document.getElementById('editDepartment').value = user.department || '';
     document.getElementById('editIsActive').checked = user.active;
     document.getElementById('statusText').textContent = user.active ? 'Active' : 'Inactive';
     
     if (user.role === 'student') {
         document.getElementById('editStudentFields').style.display = 'block';
         document.getElementById('editTeacherFields').style.display = 'none';
         document.getElementById('editRollNo').value = user.rollNo || '';
         document.getElementById('editClassName').value = user.className || '';
     } else if (user.role === 'teacher') {
         document.getElementById('editTeacherFields').style.display = 'block';
         document.getElementById('editStudentFields').style.display = 'none';
         document.getElementById('editSubjects').value = user.subjects || '';
     } else {
         document.getElementById('editStudentFields').style.display = 'none';
         document.getElementById('editTeacherFields').style.display = 'none';
     }
     modal.show();
 })
 .catch(function(err) {
     console.error("Edit User Error:", err);
     Swal.fire("Error", "Failed to load user data", "error");
 });
}

function editUserFromView() {
 var viewModal = bootstrap.Modal.getInstance(document.getElementById('viewUserModal'));
 if (viewModal) viewModal.hide();
 setTimeout(function() { editUser(currentUserId); }, 300);
}

function updateUser() {
 var form = document.getElementById("editUserForm");
 var formData = new FormData(form);
 
 if (!formData.get('username') || !formData.get('email') || !formData.get('fullName')) {
     Swal.fire("Validation Error", "Please fill all required fields", "warning");
     return;
 }
 //paswd
 var password = formData.get('password');
 if (password && password.length < 6) {
     Swal.fire("Validation Error", "Password must be at least 6 characters", "warning");
     return;
 }
 
 var isActiveCheckbox = document.querySelector('#editUserForm input[name="isActive"]');
 formData.set('isActive', isActiveCheckbox && isActiveCheckbox.checked ? 'true' : 'false');
 
 var data = new URLSearchParams(formData);
 data.append("action", "update");
 
 Swal.fire({ title: 'Updating User...', allowOutsideClick: false, didOpen: function() { Swal.showLoading(); } });

 fetch("UserServlet", {
     method: "POST",
     headers: { "Content-Type": "application/x-www-form-urlencoded" },
     body: data.toString()
 })
 .then(function(res) { return res.json(); })
 .then(function(result) {
     Swal.close();
     if (result.success) {
         Swal.fire({ icon: "success", title: "Updated!", text: result.message, timer: 2000 })
             .then(function() { location.reload(); });
     } else {
         Swal.fire("Error", result.message, "error");
     }
 })
 .catch(function(err) {
     console.error("Update Error:", err);
     Swal.close();
     Swal.fire("Error", "Failed to update user", "error");
 });
}

function deleteUser(id) {
 Swal.fire({
     title: "Delete User?",
     text: "This action cannot be undone!",
     icon: "warning",
     showCancelButton: true,
     confirmButtonColor: "#dc3545",
     confirmButtonText: "Yes, delete it!"
 }).then(function(res) {
     if (!res.isConfirmed) return;
     
     Swal.fire({ title: 'Deleting...', allowOutsideClick: false, didOpen: function() { Swal.showLoading(); } });

     fetch("UserServlet", {
         method: "POST",
         headers: { "Content-Type": "application/x-www-form-urlencoded" },
         body: "action=delete&id=" + id
     })
     .then(function(res) { return res.json(); })
     .then(function(result) {
         Swal.close();
         if (result.success) {
             Swal.fire({ icon: "success", title: "Deleted!", text: result.message, timer: 2000 })
                 .then(function() { location.reload(); });
         } else {
             Swal.fire("Error", result.message, "error");
         }
     })
     .catch(function(err) {
         console.error("Delete Error:", err);
         Swal.close();
         Swal.fire("Error", "Failed to delete user", "error");
     });
 });
}

function exportToExcel(tableType) {
 var state = tableState[tableType];
 if (!state || state.filteredRows.length === 0) {
     Swal.fire({ icon: "warning", title: "No Data", text: "Nothing to export", timer: 2000 });
     return;
 }

 var table = document.getElementById(tableType + "TableBody").closest("table");
 var headers = [];
 var headerCells = table.querySelectorAll("thead th");
 for (var i = 0; i < headerCells.length; i++) {
     var text = headerCells[i].innerText.trim();
     if (text !== "Actions" && text !== "") headers.push(text);
 }

 var csv = headers.join(",") + "\n";

 for (var j = 0; j < state.filteredRows.length; j++) {
     var cells = state.filteredRows[j].querySelectorAll("td");
     var rowData = [];
     for (var k = 0; k < cells.length - 1; k++) {
         var text = cells[k].innerText.trim().replace(/\n/g, " ").replace(/,/g, ";").replace(/"/g, '""');
         rowData.push('"' + text + '"');
     }
     csv += rowData.join(",") + "\n";
 }

 var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
 var link = document.createElement("a");
 link.href = URL.createObjectURL(blob);
 link.download = tableType + "_users_" + new Date().toISOString().split('T')[0] + ".csv";
 link.style.visibility = "hidden";
 document.body.appendChild(link);
 link.click();
 document.body.removeChild(link);
 
 Swal.fire({ icon: "success", title: "Exported!", text: "CSV downloaded", timer: 2000 });
}

function filterTable(tableType) {
 var state = tableState[tableType];
 var searchInput = document.getElementById(tableType + 'Search');
 var tableBody = document.getElementById(tableType + 'TableBody');
 
 state.searchTerm = searchInput ? searchInput.value.toLowerCase() : '';
 state.statusFilter = getFilterValue(tableType, 'StatusFilter');
 state.deptFilter = getFilterValue(tableType, 'DeptFilter');
 state.classFilter = getFilterValue(tableType, 'ClassFilter');
 state.roleFilter = getFilterValue(tableType, 'RoleFilter');
 state.currentPage = 1;
 
 var allRows = tableBody.querySelectorAll('tr');
 var rows = [];
 for (var i = 0; i < allRows.length; i++) rows.push(allRows[i]);
 
 state.filteredRows = rows.filter(function(row) {
     return matchesAllFilters(row, state, tableType);
 });
 
 sortRows(tableType);
 updateTableDisplay(tableType);
}

function getFilterValue(tableType, filterName) {
 var elem = document.getElementById(tableType + filterName);
 return elem ? elem.value : 'all';
}

function matchesAllFilters(row, state, tableType) {
 var matchesSearch = !state.searchTerm || checkSearchMatch(row, state.searchTerm);
 var matchesStatus = state.statusFilter === 'all' || row.getAttribute('data-status') === state.statusFilter;
 var matchesDept = true;
 var matchesClass = true;
 var matchesRole = true;
 
 if (tableType === 'teacher' || tableType === 'student' || tableType === 'all-users') {
     var dept = row.getAttribute('data-department') || '';
     matchesDept = state.deptFilter === 'all' || dept === state.deptFilter.toLowerCase();
 }
 
 if (tableType === 'student') {
     var className = row.getAttribute('data-class') || '';
     matchesClass = state.classFilter === 'all' || className === state.classFilter.toLowerCase();
 }
 
 if (tableType === 'all-users') {
     matchesRole = state.roleFilter === 'all' || row.getAttribute('data-role') === state.roleFilter;
 }
 
 return matchesSearch && matchesStatus && matchesDept && matchesClass && matchesRole;
}

function checkSearchMatch(row, searchTerm) {
 var fields = ['name', 'username', 'email', 'phone', 'department', 'subjects', 'rollno', 'class'];
 for (var i = 0; i < fields.length; i++) {
     var value = row.getAttribute('data-' + fields[i]) || '';
     if (value.includes(searchTerm)) return true;
 }
 return false;
}

function sortTable(tableType) {
 var sortBy = document.getElementById(tableType + 'SortBy').value;
 tableState[tableType].sortBy = sortBy;
 sortRows(tableType);
 updateTableDisplay(tableType);
}

function sortRows(tableType) {
 var state = tableState[tableType];
 state.filteredRows.sort(function(a, b) {
     switch(state.sortBy) {
         case 'id': return parseInt(a.getAttribute('data-id')) - parseInt(b.getAttribute('data-id'));
         case 'name': return a.getAttribute('data-name').localeCompare(b.getAttribute('data-name'));
         case 'name_desc': return b.getAttribute('data-name').localeCompare(a.getAttribute('data-name'));
         case 'username': return a.getAttribute('data-username').localeCompare(b.getAttribute('data-username'));
         case 'email': return a.getAttribute('data-email').localeCompare(b.getAttribute('data-email'));
         case 'dept': return (a.getAttribute('data-department') || '').localeCompare(b.getAttribute('data-department') || '');
         case 'role': return a.getAttribute('data-role').localeCompare(b.getAttribute('data-role'));
         default: return 0;
     }
 });
}

function updateTableDisplay(tableType) {
 var state = tableState[tableType];
 var tableBody = document.getElementById(tableType + 'TableBody');
 var noResults = document.getElementById(tableType + 'NoResults');
 
 var allRows = tableBody.querySelectorAll('tr');
 for (var i = 0; i < allRows.length; i++) allRows[i].style.display = 'none';
 
 var startIdx = (state.currentPage - 1) * state.pageSize;
 var endIdx = Math.min(startIdx + state.pageSize, state.filteredRows.length);
 
 for (var j = startIdx; j < endIdx; j++) {
     if (state.filteredRows[j]) state.filteredRows[j].style.display = '';
 }
 
 updateCounts(tableType);
 
 if (noResults) {
     noResults.style.display = state.filteredRows.length === 0 ? 'block' : 'none';
     tableBody.style.display = state.filteredRows.length === 0 ? 'none' : '';
 }
 
 updatePagination(tableType);
}

function updateCounts(tableType) {
 var state = tableState[tableType];
 var showingCount = document.getElementById(tableType + 'ShowingCount');
 var totalCount = document.getElementById(tableType + 'TotalCount');
 if (showingCount) showingCount.textContent = state.filteredRows.length;
 if (totalCount) totalCount.textContent = state.totalRows;
}

function updatePagination(tableType) {
 var state = tableState[tableType];
 var pagination = document.getElementById(tableType + 'Pagination');
 var pageSizeSelect = document.getElementById(tableType + 'PageSize');
 
 if (pageSizeSelect) state.pageSize = parseInt(pageSizeSelect.value);
 
 var totalPages = Math.ceil(state.filteredRows.length / state.pageSize);
 state.currentPage = Math.min(state.currentPage, totalPages || 1);
 
 if (pagination && totalPages > 1) {
     var html = buildPaginationHTML(tableType, state.currentPage, totalPages);
     pagination.querySelector('ul').innerHTML = html;
     pagination.style.display = 'block';
 } else if (pagination) {
     pagination.style.display = 'none';
 }
}

function buildPaginationHTML(tableType, currentPage, totalPages) {
 var html = '<li class="page-item ' + (currentPage == 1 ? 'disabled' : '') + '">' +
     '<a class="page-link" href="#" onclick="changePage(\'' + tableType + '\', ' + (currentPage - 1) + ')">&laquo;</a></li>';
 
 var maxVisible = 5;
 var startPage = Math.max(1, currentPage - Math.floor(maxVisible / 2));
 var endPage = Math.min(totalPages, startPage + maxVisible - 1);
 
 if (endPage - startPage + 1 < maxVisible) startPage = Math.max(1, endPage - maxVisible + 1);
 
 for (var i = startPage; i <= endPage; i++) {
     html += '<li class="page-item ' + (i == currentPage ? 'active' : '') + '">' +
         '<a class="page-link" href="#" onclick="changePage(\'' + tableType + '\', ' + i + ')">' + i + '</a></li>';
 }
 
 html += '<li class="page-item ' + (currentPage == totalPages ? 'disabled' : '') + '">' +
     '<a class="page-link" href="#" onclick="changePage(\'' + tableType + '\', ' + (currentPage + 1) + ')">&raquo;</a></li>';
 
 return html;
}

function changePage(tableType, page) {
 tableState[tableType].currentPage = page;
 updateTableDisplay(tableType);
}

function clearFilters(tableType) {
 var searchInput = document.getElementById(tableType + 'Search');
 if (searchInput) searchInput.value = '';
 
 var filters = ['StatusFilter', 'DeptFilter', 'ClassFilter', 'RoleFilter', 'SortBy', 'PageSize'];
 for (var i = 0; i < filters.length; i++) {
     var elem = document.getElementById(tableType + filters[i]);
     if (elem) elem.value = (filters[i] === 'SortBy' ? 'id' : (filters[i] === 'PageSize' ? '10' : 'all'));
 }
 
 filterTable(tableType);
}

function toggleFields() {
 var role = document.getElementById('userRole').value;
 document.getElementById('studentFields').style.display = role === 'student' ? 'block' : 'none';
 document.getElementById('teacherFields').style.display = role === 'teacher' ? 'block' : 'none';
}

function toggleEditFields() {
 var role = document.getElementById('editUserRole').value;
 document.getElementById('editStudentFields').style.display = role === 'student' ? 'block' : 'none';
 document.getElementById('editTeacherFields').style.display = role === 'teacher' ? 'block' : 'none';
}

function togglePassword(fieldId) {
 var field = document.getElementById(fieldId);
 var icon = event.currentTarget.querySelector('i');
 if (field.type === 'password') {
     field.type = 'text';
     icon.classList.remove('fa-eye');
     icon.classList.add('fa-eye-slash');
 } else {
     field.type = 'password';
     icon.classList.remove('fa-eye-slash');
     icon.classList.add('fa-eye');
 }
}

function showSection(section) {
 document.getElementById('dashboard-content').style.display = 'none';
 var containers = document.querySelectorAll('.table-container');
 for (var i = 0; i < containers.length; i++) containers[i].classList.remove('active');
 
 var links = document.querySelectorAll('.nav-link');
 for (var j = 0; j < links.length; j++) {
     links[j].classList.remove('active');
     if (links[j].getAttribute('data-section') === section) links[j].classList.add('active');
 }
 
 var titles = {
     'dashboard': ['Dashboard Overview', 'Welcome back!'],
     'admin': ['Admin Management', 'Add, View, Update, Delete Administrators'],
     'teacher': ['Teacher Management', 'Add, View, Update, Delete Teachers'],
     'student': ['Student Management', 'Add, View, Update, Delete Students'],
     'all-users': ['All System Users', 'View all users in the system']
 };
 
 if (section === 'dashboard') {
     document.getElementById('dashboard-content').style.display = 'block';
 } else {
     var elem = document.getElementById(section + '-management') || document.getElementById('all-users');
     if (elem) elem.classList.add('active');
 }
 
 if (titles[section]) updatePageTitle(titles[section][0], titles[section][1]);
 
 if (window.innerWidth <= 992) {
     var sidebar = document.querySelector('.sidebar');
     if (sidebar) sidebar.classList.remove('active');
 }
}

function updatePageTitle(title, subtitle) {
 document.getElementById('page-title').textContent = title;
 document.getElementById('page-subtitle').textContent = subtitle;
}

function toggleNavSection(section) {
 var links = document.getElementById(section + '-links');
 var title = document.querySelector('[onclick="toggleNavSection(\'' + section + '\')"]');
 if (links && title) {
     links.classList.toggle('collapsed');
     var icon = title.querySelector('i');
     if (icon) icon.classList.toggle('rotated');
 }
}

function showAddUserModal(role) {
 if (typeof role === 'undefined') role = '';
 var modal = new bootstrap.Modal(document.getElementById('addUserModal'));
 document.getElementById('addUserForm').reset();
 if (role) {
     document.getElementById('userRole').value = role;
     toggleFields();
 }
 modal.show();
}

function logout() {
 Swal.fire({
     title: 'Logout?',
     text: "Are you sure?",
     icon: 'question',
     showCancelButton: true,
     confirmButtonColor: '#dc3545',
     confirmButtonText: 'Yes, logout'
 }).then(function(result) {
     if (result.isConfirmed) window.location.href = 'login?action=logout';
 });
}

function adjustNavigationForMobile() {
 var navSections = document.querySelectorAll('.nav-section');
 for (var i = 0; i < navSections.length; i++) {
     var links = navSections[i].querySelector('.nav-links');
     var icon = navSections[i].querySelector('.nav-title i');
     if (window.innerWidth <= 768) {
         if (navSections[i].querySelector('.nav-link.active')) {
             if (links) links.classList.remove('collapsed');
             if (icon) icon.classList.add('rotated');
         } else {
             if (links) links.classList.add('collapsed');
             if (icon) icon.classList.remove('rotated');
         }
     } else {
         if (links) links.classList.remove('collapsed');
         if (icon) icon.classList.add('rotated');
     }
 }
}

console.log('EduTrack Pro Admin Dashboard v1.0.0 - Ready');