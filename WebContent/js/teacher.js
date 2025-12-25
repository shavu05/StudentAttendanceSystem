// ===============================
// GLOBAL STORE
// ===============================
let attendanceChanges = {};

// ===============================
// MARK ATTENDANCE
// ===============================
function markStatusSimple(studentId, status) {
    console.log('✅ Marking:', studentId, status);

    const statusCell = document.querySelector('.status-cell-' + studentId);

    if (!statusCell) {
        console.error('❌ Status cell not found for student:', studentId);
        Swal.fire('Error', 'Could not find student status cell', 'error');
        return;
    }

    statusCell.innerHTML =
        status === 'present'
            ? '<span class="attendance-badge badge-present">Present</span>'
            : '<span class="attendance-badge badge-absent">Absent</span>';

    attendanceChanges[studentId] = status;

    Swal.fire({
        toast: true,
        position: 'top-end',
        icon: 'success',
        title: 'Marked ' + status,
        showConfirmButton: false,
        timer: 800
    });
}

// ===============================
// PAGE NAVIGATION
// ===============================
function showPage(pageId, el) {
    document.querySelectorAll('.page-section').forEach(s => s.classList.remove('active'));
    document.getElementById(pageId).classList.add('active');

    document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
    if (el) el.classList.add('active');

    if (pageId === 'dashboard') loadDashboardChart();
}

// ===============================
// MARK ALL PRESENT
// ===============================
function markAllPresent() {
    Swal.fire({
        title: 'Mark All Present?',
        text: 'This will mark all visible students as present',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: 'Yes, mark all'
    }).then(result => {
        if (result.isConfirmed) {
            document.querySelectorAll('#studentTableBody tr.student-row').forEach(row => {
                if (row.style.display !== 'none') {
                    const id = row.getAttribute('data-student-id');
                    if (id) markStatusSimple(parseInt(id), 'present');
                }
            });
        }
    });
}

// ===============================
// FILTER BY CLASS
// ===============================
function filterStudentsByClass() {
    const filter = document.getElementById('classFilter').value;
    document.querySelectorAll('#studentTableBody tr.student-row').forEach(row => {
        const cls = row.getAttribute('data-class');
        row.style.display = (filter === '' || cls === filter) ? '' : 'none';
    });
}

// ===============================
// SAVE ATTENDANCE
// ===============================
function saveAllAttendance() {
    const date = document.getElementById('attendanceDate').value;

    const teacherId =
        (typeof TEACHER_ID !== "undefined" && TEACHER_ID !== "null")
            ? TEACHER_ID
            : "0";

    if (teacherId === "0") {
        Swal.fire('Error', 'Teacher ID not found. Please login again.', 'error');
        return;
    }

    if (Object.keys(attendanceChanges).length === 0) {
        Swal.fire('No Changes', 'Please mark attendance first', 'info');
        return;
    }

    document.getElementById('loading').style.display = 'flex';

    $.ajax({
        url: 'AttendanceServlet',
        method: 'POST',
        data: {
            action: 'saveAttendance',
            date,
            teacherId,
            attendance: JSON.stringify(attendanceChanges)
        },
        success: res => {
            document.getElementById('loading').style.display = 'none';
            if (res.success) {
                Swal.fire('Success', res.message || 'Attendance saved', 'success')
                    .then(() => location.reload());
            } else {
                Swal.fire('Error', res.message || 'Save failed', 'error');
            }
        },
        error: (_, __, err) => {
            document.getElementById('loading').style.display = 'none';
            Swal.fire('Error', err, 'error');
        }
    });
}

// ===============================
// VIEW ATTENDANCE
// ===============================
function viewAttendanceRecords() {
    const startDate = document.getElementById('viewStartDate').value;
    const endDate = document.getElementById('viewEndDate').value;
    const cls = document.getElementById('viewClassFilter').value;

    if (!startDate || !endDate) {
        Swal.fire('Error', 'Select start and end dates', 'warning');
        return;
    }

    document.getElementById('loading').style.display = 'flex';

    $.ajax({
        url: 'AttendanceServlet',
        method: 'GET',
        dataType: 'json',
        data: { action: 'viewAttendance', startDate, endDate, class: cls },
        success: data => {
            document.getElementById('loading').style.display = 'none';

            if (data.success && data.records.length > 0) {
                let html = `
                <table class="table table-bordered table-hover">
                    <thead class="table-dark">
                        <tr>
                            <th>Date</th><th>Roll No</th><th>Name</th><th>Class</th><th>Status</th>
                        </tr>
                    </thead><tbody>`;

                data.records.forEach(r => {
                    html += `
                    <tr>
                        <td>${r.date}</td>
                        <td>${r.rollNo}</td>
                        <td>${r.fullName}</td>
                        <td>${r.className}</td>
                        <td>${r.status}</td>
                    </tr>`;
                });

                html += '</tbody></table>';
                document.getElementById('viewAttendanceResults').innerHTML = html;
            } else {
                document.getElementById('viewAttendanceResults').innerHTML =
                    '<div class="alert alert-warning">No records found</div>';
            }
        },
        error: (_, __, err) => {
            document.getElementById('loading').style.display = 'none';
            Swal.fire('Error', err, 'error');
        }
    });
}

// ===============================
// DASHBOARD CHART
// ===============================
function loadDashboardChart() {
    $.get('AttendanceServlet', { action: 'getChartData' }, res => {
        if (!res.success) return;

        const ctx = document.getElementById('attendanceChart');
        if (window.attendanceChartInstance) {
            window.attendanceChartInstance.destroy();
        }

        window.attendanceChartInstance = new Chart(ctx, {
            type: 'line',
            data: {
                labels: res.chartData.labels,
                datasets: [
                    { label: 'Present', data: res.chartData.present, borderColor: '#06d6a0' },
                    { label: 'Absent', data: res.chartData.absent, borderColor: '#ef476f' }
                ]
            }
        });
    });
}

// ===============================
// PAGE LOAD
// ===============================
$(document).ready(() => {
    console.log('✅ Attendance JS Loaded');
    loadDashboardChart();
});

// ===============================
// LOGOUT
// ===============================
function confirmLogout() {
    Swal.fire({
        title: 'Logout?',
        icon: 'question',
        showCancelButton: true
    }).then(r => {
        if (r.isConfirmed) window.location.href = 'login?action=logout';
    });
}
