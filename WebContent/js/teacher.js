// ============================================
// GLOBAL VARIABLES
// ============================================
let attendanceChanges = {};
let currentViewedRecords = [];

// ============================================
// MARK ATTENDANCE FUNCTIONS
// ============================================

// Mark individual student attendance
function markStatusSimple(studentId, status) {
    console.log('✅ Marking:', studentId, status);
    
    const statusCell = document.querySelector('.status-cell-' + studentId);
    
    if (!statusCell) {
        console.error('❌ Status cell not found for student:', studentId);
        Swal.fire('Error', 'Could not find student status cell', 'error');
        return;
    }
    
    // Update display
    if (status === 'present') {
        statusCell.innerHTML = '<span class="attendance-badge badge-present">Present</span>';
    } else {
        statusCell.innerHTML = '<span class="attendance-badge badge-absent">Absent</span>';
    }
    
    // Store change
    attendanceChanges[studentId] = status;
    console.log('Current changes:', attendanceChanges);
    
    // Show success toast
    Swal.fire({
        toast: true,
        position: 'top-end',
        icon: 'success',
        title: 'Marked ' + status,
        showConfirmButton: false,
        timer: 800
    });
}

// Mark all visible students as present
function markAllPresent() {
    Swal.fire({
        title: 'Mark All Present?',
        text: 'This will mark all visible students as present',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: 'Yes, mark all',
        confirmButtonColor: '#28a745'
    }).then((result) => {
        if (result.isConfirmed) {
            const visibleRows = document.querySelectorAll('#studentTableBody tr.student-row');
            let count = 0;
            visibleRows.forEach(row => {
                if (row.style.display !== 'none') {
                    const studentId = row.getAttribute('data-student-id');
                    if (studentId) {
                        markStatusSimple(parseInt(studentId), 'present');
                        count++;
                    }
                }
            });
            
            Swal.fire({
                toast: true,
                position: 'top-end',
                icon: 'success',
                title: `Marked ${count} students present`,
                showConfirmButton: false,
                timer: 1500
            });
        }
    });
}

// Filter students by class
function filterStudentsByClass() {
    const classFilter = document.getElementById('classFilter').value;
    const rows = document.querySelectorAll('#studentTableBody tr.student-row');
    
    rows.forEach(row => {
        const studentClass = row.getAttribute('data-class');
        if (classFilter === '' || studentClass === classFilter) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}

// Save all attendance - FIXED VERSION
function saveAllAttendance() {
    const date = document.getElementById('attendanceDate').value;
    const currentTeacherId = typeof TEACHER_ID !== 'undefined' ? TEACHER_ID : null;
    
    console.log('🔍 Debug Info:', {
        date: date,
        teacherId: currentTeacherId,
        changes: attendanceChanges,
        changesCount: Object.keys(attendanceChanges).length
    });
    
    // Validate teacher ID
    if (!currentTeacherId || currentTeacherId === '0' || currentTeacherId === 'null' || currentTeacherId === 'undefined') {
        Swal.fire({
            icon: 'error',
            title: 'Session Error',
            text: 'Teacher ID not found. Please log in again.',
            confirmButtonText: 'Go to Login'
        }).then(() => {
            window.location.href = 'login.jsp';
        });
        return;
    }
    
    // Check if any attendance was marked
    if (Object.keys(attendanceChanges).length === 0) {
        Swal.fire({
            icon: 'info',
            title: 'No Changes',
            text: 'Please mark attendance for at least one student before saving.'
        });
        return;
    }
    
    // Validate date
    if (!date) {
        Swal.fire('Error', 'Please select a date', 'warning');
        return;
    }
    
    console.log('💾 Saving attendance:', { 
        date: date, 
        teacherId: currentTeacherId, 
        attendance: attendanceChanges 
    });
    
    // Show loading
    document.getElementById('loading').style.display = 'flex';
    
    $.ajax({
        url: 'AttendanceServlet',
        method: 'POST',
        dataType: 'json',
        data: {
            action: 'saveAttendance',
            date: date,
            teacherId: currentTeacherId,
            attendance: JSON.stringify(attendanceChanges)
        },
        success: function(response) {
            console.log('✅ Server Response:', response);
            document.getElementById('loading').style.display = 'none';
            
            let data = response;
            if (typeof response === 'string') {
                try {
                    data = JSON.parse(response);
                } catch (e) {
                    console.error('Failed to parse response:', e);
                }
            }
            
            if (data.success) {
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: data.message || 'Attendance saved successfully',
                    timer: 2000,
                    showConfirmButton: false
                }).then(() => {
                    attendanceChanges = {};
                    location.reload();
                });
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Failed to Save',
                    text: data.message || 'An error occurred while saving attendance'
                });
            }
        },
        error: function(xhr, status, error) {
            console.error('❌ AJAX Error:', {
                status: status,
                error: error,
                response: xhr.responseText
            });
            document.getElementById('loading').style.display = 'none';
            
            Swal.fire({
                icon: 'error',
                title: 'Connection Error',
                html: 'Failed to save attendance.<br><small>' + error + '</small>'
            });
        }
    });
}

// ============================================
// PAGE NAVIGATION
// ============================================

function showPage(pageId) {
    // Hide all sections
    document.querySelectorAll('.page-section').forEach(section => {
        section.classList.remove('active');
    });
    
    // Show selected section
    const targetPage = document.getElementById(pageId);
    if (targetPage) {
        targetPage.classList.add('active');
    }
    
    // Update nav links
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
    });
    if (event && event.target) {
        event.target.classList.add('active');
    }
    
    // Load chart if dashboard
    if (pageId === 'dashboard') {
        loadDashboardChart();
    }
}

// ============================================
// VIEW ATTENDANCE FUNCTIONS
// ============================================

// View by date range
function viewAttendanceByRange() {
    const startDate = document.getElementById('viewStartDate').value;
    const endDate = document.getElementById('viewEndDate').value;
    const classFilter = document.getElementById('viewClassFilter').value;
    
    console.log('📊 View by Range:', { startDate, endDate, classFilter });
    
    if (!startDate || !endDate) {
        Swal.fire({
            icon: 'warning',
            title: 'Missing Dates',
            text: 'Please select both start and end dates'
        });
        return;
    }
    
    if (new Date(startDate) > new Date(endDate)) {
        Swal.fire({
            icon: 'error',
            title: 'Invalid Date Range',
            text: 'Start date cannot be after end date'
        });
        return;
    }
    
    fetchAttendanceRecords({
        action: 'viewAttendance',
        startDate: startDate,
        endDate: endDate,
        class: classFilter
    });
}

// View by specific date
function viewAttendanceByDate() {
    const singleDateEl = document.getElementById('viewSingleDate');
    const classFilterEl = document.getElementById('viewSingleClassFilter');
    
    if (!singleDateEl) {
        console.error('viewSingleDate element not found');
        return;
    }
    
    const singleDate = singleDateEl.value;
    const classFilter = classFilterEl ? classFilterEl.value : '';
    
    console.log('📅 View by Single Date:', { singleDate, classFilter });
    
    if (!singleDate) {
        Swal.fire({
            icon: 'warning',
            title: 'Missing Date',
            text: 'Please select a date'
        });
        return;
    }
    
    fetchAttendanceRecords({
        action: 'viewAttendance',
        startDate: singleDate,
        endDate: singleDate,
        class: classFilter
    });
}

// Legacy function for compatibility
function viewAttendanceRecords() {
    viewAttendanceByRange();
}

// Common fetch function
function fetchAttendanceRecords(params) {
    document.getElementById('loading').style.display = 'flex';
    
    $.ajax({
        url: 'AttendanceServlet',
        method: 'GET',
        dataType: 'json',
        data: params,
        success: function(response) {
            document.getElementById('loading').style.display = 'none';
            
            console.log('✅ Attendance Records Response:', response);
            
            let data = response;
            if (typeof response === 'string') {
                try {
                    data = JSON.parse(response);
                } catch (e) {
                    console.error('Parse error:', e);
                    Swal.fire('Error', 'Invalid server response', 'error');
                    return;
                }
            }
            
            if (data.success && data.records && data.records.length > 0) {
                currentViewedRecords = data.records;
                
                // Show export button if exists
                const exportBtn = document.getElementById('exportViewBtn');
                if (exportBtn) {
                    exportBtn.style.display = 'inline-block';
                }
                
                // Calculate statistics
                const totalRecords = data.records.length;
                const presentCount = data.records.filter(r => r.status === 'present').length;
                const absentCount = data.records.filter(r => r.status === 'absent').length;
                
                // Update stats display if exists
                const recordStats = document.getElementById('recordStats');
                if (recordStats) {
                    recordStats.innerHTML = 
                        `<span class="badge bg-primary me-2">Total: ${totalRecords}</span>
                         <span class="badge bg-success me-2">Present: ${presentCount}</span>
                         <span class="badge bg-danger">Absent: ${absentCount}</span>`;
                }
                
                // Build table
                let html = '<div class="table-responsive">';
                html += '<table class="table table-bordered table-striped table-hover" id="viewResultsTable">';
                
                html += `<thead class="table-dark">
                    <tr>
                        <th><i class="fas fa-calendar"></i> Date</th>
                        <th><i class="fas fa-id-badge"></i> Roll No</th>
                        <th><i class="fas fa-user"></i> Student Name</th>
                        <th><i class="fas fa-chalkboard"></i> Class</th>
                        <th><i class="fas fa-check-circle"></i> Status</th>
                    </tr>
                </thead>`;
                
                html += '<tbody>';
                
                data.records.forEach((record) => {
                    const statusBadge = record.status === 'present' 
                        ? '<span class="badge bg-success"><i class="fas fa-check"></i> Present</span>'
                        : '<span class="badge bg-danger"><i class="fas fa-times"></i> Absent</span>';
                    
                    html += `<tr>
                        <td>${record.date}</td>
                        <td><strong>${record.rollNo || 'N/A'}</strong></td>
                        <td>${record.fullName}</td>
                        <td>${record.className || 'N/A'}</td>
                        <td>${statusBadge}</td>
                    </tr>`;
                });
                
                html += '</tbody></table></div>';
                
                // Summary cards
                html += `
                <div class="row mt-4">
                    <div class="col-md-4">
                        <div class="card bg-primary text-white">
                            <div class="card-body text-center">
                                <h3>${totalRecords}</h3>
                                <p class="mb-0">Total Records</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card bg-success text-white">
                            <div class="card-body text-center">
                                <h3>${presentCount}</h3>
                                <p class="mb-0">Present</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card bg-danger text-white">
                            <div class="card-body text-center">
                                <h3>${absentCount}</h3>
                                <p class="mb-0">Absent</p>
                            </div>
                        </div>
                    </div>
                </div>`;
                
                document.getElementById('viewAttendanceResults').innerHTML = html;
                
                Swal.fire({
                    toast: true,
                    position: 'top-end',
                    icon: 'success',
                    title: `Found ${totalRecords} records`,
                    showConfirmButton: false,
                    timer: 2000
                });
                
            } else {
                currentViewedRecords = [];
                
                const exportBtn = document.getElementById('exportViewBtn');
                if (exportBtn) {
                    exportBtn.style.display = 'none';
                }
                
                const recordStats = document.getElementById('recordStats');
                if (recordStats) {
                    recordStats.innerHTML = '';
                }
                
                document.getElementById('viewAttendanceResults').innerHTML = `
                    <div class="text-center py-5">
                        <i class="fas fa-inbox fa-3x text-warning mb-3"></i>
                        <h5 class="text-warning">No Records Found</h5>
                        <p class="text-muted">No attendance records found for the selected criteria.</p>
                        <p class="text-muted small">Try selecting different dates or class filter.</p>
                    </div>`;
            }
        },
        error: function(xhr, status, error) {
            document.getElementById('loading').style.display = 'none';
            console.error('❌ Error:', { status, error, response: xhr.responseText });
            
            Swal.fire({
                icon: 'error',
                title: 'Connection Error',
                text: 'Failed to fetch records: ' + error
            });
        }
    });
}

// ============================================
// EXPORT FUNCTIONS
// ============================================

// Export viewed attendance
function exportViewedAttendance() {
    if (!currentViewedRecords || currentViewedRecords.length === 0) {
        Swal.fire({
            icon: 'warning',
            title: 'No Data',
            text: 'Please search for attendance records first'
        });
        return;
    }
    
    Swal.fire({
        title: 'Export Options',
        html: `
            <div class="text-start">
                <p>Export <strong>${currentViewedRecords.length}</strong> records to:</p>
                <div class="form-check mb-2">
                    <input class="form-check-input" type="radio" name="exportFormat" id="exportCSV" value="csv" checked>
                    <label class="form-check-label" for="exportCSV">
                        <i class="fas fa-file-csv text-success"></i> CSV File (Excel Compatible)
                    </label>
                </div>
                <div class="form-check">
                    <input class="form-check-input" type="radio" name="exportFormat" id="exportXLS" value="xls">
                    <label class="form-check-label" for="exportXLS">
                        <i class="fas fa-file-excel text-success"></i> XLS File (Excel Format)
                    </label>
                </div>
            </div>
        `,
        showCancelButton: true,
        confirmButtonText: '<i class="fas fa-download"></i> Download',
        confirmButtonColor: '#28a745',
        cancelButtonText: 'Cancel'
    }).then((result) => {
        if (result.isConfirmed) {
            const format = document.querySelector('input[name="exportFormat"]:checked').value;
            
            if (format === 'csv') {
                exportToCSV();
            } else {
                exportToXLS();
            }
        }
    });
}

// Export to CSV
function exportToCSV() {
    let csv = '\uFEFF'; // UTF-8 BOM
    
    csv += 'Date,Roll No,Student Name,Class,Status\n';
    
    currentViewedRecords.forEach(record => {
        csv += `${record.date},`;
        csv += `"${record.rollNo || 'N/A'}",`;
        csv += `"${record.fullName}",`;
        csv += `"${record.className || 'N/A'}",`;
        csv += `${record.status}\n`;
    });
    
    downloadFile(csv, 'Attendance_Records.csv', 'text/csv;charset=utf-8;');
    
    Swal.fire({
        toast: true,
        position: 'top-end',
        icon: 'success',
        title: 'CSV Downloaded!',
        showConfirmButton: false,
        timer: 2000
    });
}

// Export to XLS
function exportToXLS() {
    const presentCount = currentViewedRecords.filter(r => r.status === 'present').length;
    const absentCount = currentViewedRecords.filter(r => r.status === 'absent').length;
    
    let html = `
        <html xmlns:o="urn:schemas-microsoft-com:office:office" 
              xmlns:x="urn:schemas-microsoft-com:office:excel" 
              xmlns="http://www.w3.org/TR/REC-html40">
        <head>
            <meta charset="UTF-8">
            <!--[if gte mso 9]>
            <xml>
                <x:ExcelWorkbook>
                    <x:ExcelWorksheets>
                        <x:ExcelWorksheet>
                            <x:Name>Attendance Records</x:Name>
                            <x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions>
                        </x:ExcelWorksheet>
                    </x:ExcelWorksheets>
                </x:ExcelWorkbook>
            </xml>
            <![endif]-->
            <style>
                table { border-collapse: collapse; }
                th { background-color: #4472C4; color: white; font-weight: bold; padding: 10px; border: 1px solid #000; }
                td { padding: 8px; border: 1px solid #000; }
                .present { background-color: #C6EFCE; color: #006100; }
                .absent { background-color: #FFC7CE; color: #9C0006; }
            </style>
        </head>
        <body>
            <h2>Attendance Records</h2>
            <p>Generated on: ${new Date().toLocaleString()}</p>
            <p>Total Records: ${currentViewedRecords.length}</p>
            <table>
                <thead>
                    <tr><th>Date</th><th>Roll No</th><th>Student Name</th><th>Class</th><th>Status</th></tr>
                </thead>
                <tbody>`;
    
    currentViewedRecords.forEach(record => {
        const statusClass = record.status === 'present' ? 'present' : 'absent';
        html += `<tr>
            <td>${record.date}</td>
            <td>${record.rollNo || 'N/A'}</td>
            <td>${record.fullName}</td>
            <td>${record.className || 'N/A'}</td>
            <td class="${statusClass}">${record.status.toUpperCase()}</td>
        </tr>`;
    });
    
    html += `</tbody></table>
        <br><h3>Summary</h3>
        <table>
            <tr><td><strong>Total Records</strong></td><td>${currentViewedRecords.length}</td></tr>
            <tr><td class="present"><strong>Present</strong></td><td>${presentCount}</td></tr>
            <tr><td class="absent"><strong>Absent</strong></td><td>${absentCount}</td></tr>
            <tr><td><strong>Attendance Rate</strong></td><td>${((presentCount / currentViewedRecords.length) * 100).toFixed(1)}%</td></tr>
        </table>
        </body></html>`;
    
    downloadFile(html, 'Attendance_Records.xls', 'application/vnd.ms-excel');
    
    Swal.fire({
        toast: true,
        position: 'top-end',
        icon: 'success',
        title: 'Excel File Downloaded!',
        showConfirmButton: false,
        timer: 2000
    });
}

// Export report to Excel (from Reports section)
function exportToExcel() {
    const month = document.getElementById('reportMonth').value;
    const year = document.getElementById('reportYear').value;
    const classFilter = document.getElementById('reportClassFilter').value;
    
    const reportTable = document.querySelector('#reportResults table');
    if (!reportTable) {
        Swal.fire({
            icon: 'warning',
            title: 'No Report Found',
            text: 'Please generate the report first'
        });
        return;
    }
    
    document.getElementById('loading').style.display = 'flex';
    
    $.ajax({
        url: 'AttendanceServlet',
        method: 'GET',
        dataType: 'json',
        data: {
            action: 'generateReport',
            month: month,
            year: year,
            class: classFilter
        },
        success: function(response) {
            document.getElementById('loading').style.display = 'none';
            
            let data = response;
            if (typeof response === 'string') {
                try { data = JSON.parse(response); } catch (e) { return; }
            }
            
            if (data.success && data.report && data.report.length > 0) {
                let csv = '\uFEFF';
                csv += 'Roll No,Student Name,Class,Present Days,Absent Days,Total Days,Attendance Percentage\n';
                
                data.report.forEach(student => {
                    csv += `${student.rollNo},`;
                    csv += `"${student.fullName}",`;
                    csv += `"${student.className}",`;
                    csv += `${student.presentDays},`;
                    csv += `${student.absentDays},`;
                    csv += `${student.totalDays},`;
                    csv += `${student.percentage}%\n`;
                });
                
                const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                const filename = `Attendance_Report_${monthNames[parseInt(month) - 1]}_${year}.csv`;
                
                downloadFile(csv, filename, 'text/csv;charset=utf-8;');
                
                Swal.fire({
                    icon: 'success',
                    title: 'Export Successful',
                    text: `${data.report.length} students exported`,
                    timer: 2000
                });
            }
        },
        error: function() {
            document.getElementById('loading').style.display = 'none';
            Swal.fire('Error', 'Failed to export', 'error');
        }
    });
}

// Helper: Download file
function downloadFile(content, filename, mimeType) {
    const blob = new Blob([content], { type: mimeType });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    
    const timestamp = new Date().toISOString().slice(0, 10);
    const finalFilename = filename.replace('.', `_${timestamp}.`);
    
    a.href = url;
    a.download = finalFilename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
}

// ============================================
// GENERATE REPORT
// ============================================

function generateReport() {
    const month = document.getElementById('reportMonth').value;
    const year = document.getElementById('reportYear').value;
    const classFilter = document.getElementById('reportClassFilter').value;
    
    document.getElementById('loading').style.display = 'flex';
    
    $.ajax({
        url: 'AttendanceServlet',
        method: 'GET',
        dataType: 'json',
        data: {
            action: 'generateReport',
            month: month,
            year: year,
            class: classFilter
        },
        success: function(response) {
            document.getElementById('loading').style.display = 'none';
            
            let data = response;
            if (typeof response === 'string') {
                try { data = JSON.parse(response); } catch (e) { return; }
            }
            
            if (data.success && data.report && data.report.length > 0) {
                let html = '<div class="table-responsive">';
                html += '<table class="table table-bordered table-striped table-hover">';
                html += '<thead class="table-dark"><tr>';
                html += '<th>Roll No</th><th>Student Name</th><th>Class</th>';
                html += '<th>Present Days</th><th>Absent Days</th><th>Total Days</th><th>Attendance %</th>';
                html += '</tr></thead><tbody>';
                
                data.report.forEach(student => {
                    const percentage = parseFloat(student.percentage);
                    let badgeClass = percentage >= 75 ? 'bg-success' : percentage >= 50 ? 'bg-warning' : 'bg-danger';
                    
                    html += `<tr>
                        <td>${student.rollNo}</td>
                        <td>${student.fullName}</td>
                        <td>${student.className}</td>
                        <td><span class="badge bg-success">${student.presentDays}</span></td>
                        <td><span class="badge bg-danger">${student.absentDays}</span></td>
                        <td><strong>${student.totalDays}</strong></td>
                        <td><span class="badge ${badgeClass}">${student.percentage}%</span></td>
                    </tr>`;
                });
                
                html += '</tbody></table></div>';
                document.getElementById('reportResults').innerHTML = html;
                
                Swal.fire({ toast: true, position: 'top-end', icon: 'success', title: 'Report Generated', timer: 2000, showConfirmButton: false });
            } else {
                document.getElementById('reportResults').innerHTML = '<div class="alert alert-warning">No data available</div>';
            }
        },
        error: function() {
            document.getElementById('loading').style.display = 'none';
            Swal.fire('Error', 'Failed to generate report', 'error');
        }
    });
}

// ============================================
// DASHBOARD CHART
// ============================================

function loadDashboardChart() {
    $.ajax({
        url: 'AttendanceServlet',
        method: 'GET',
        dataType: 'json',
        data: { action: 'getChartData' },
        success: function(response) {
            if (response.success && response.chartData) {
                const ctx = document.getElementById('attendanceChart');
                
                if (window.attendanceChartInstance) {
                    window.attendanceChartInstance.destroy();
                }
                
                window.attendanceChartInstance = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: response.chartData.labels,
                        datasets: [{
                            label: 'Present',
                            data: response.chartData.present,
                            borderColor: '#06d6a0',
                            backgroundColor: 'rgba(6, 214, 160, 0.1)',
                            tension: 0.4
                        }, {
                            label: 'Absent',
                            data: response.chartData.absent,
                            borderColor: '#ef476f',
                            backgroundColor: 'rgba(239, 71, 111, 0.1)',
                            tension: 0.4
                        }]
                    },
                    options: {
                        responsive: true,
                        plugins: { legend: { position: 'top' } },
                        scales: { y: { beginAtZero: true } }
                    }
                });
            }
        },
        error: function(xhr, status, error) {
            console.error('❌ Chart Error:', error);
        }
    });
}

// ============================================
// LOGOUT
// ============================================

function confirmLogout() {
    Swal.fire({
        title: 'Logout?',
        text: 'Are you sure you want to logout?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: 'Yes, Logout',
        cancelButtonText: 'Cancel',
        confirmButtonColor: '#ef476f'
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = 'login?action=logout';
        }
    });
}

// ============================================
// STUDENT SEARCH
// ============================================

function searchStudents() {
    const searchTerm = document.getElementById('searchStudent').value.toLowerCase();
    const rows = document.querySelectorAll('#studentListBody tr');
    
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchTerm) ? '' : 'none';
    });
}

// ============================================
// INITIALIZATION
// ============================================

$(document).ready(function() {
    console.log('✅ Teacher.js loaded successfully');
    
    // Load dashboard chart
    loadDashboardChart();
    
    // Set default dates
    const today = new Date();
    const lastWeek = new Date(today);
    lastWeek.setDate(lastWeek.getDate() - 7);
    
    const formatDate = (date) => date.toISOString().split('T')[0];
    
    // Set date inputs if they exist
    const viewStartDate = document.getElementById('viewStartDate');
    const viewEndDate = document.getElementById('viewEndDate');
    const viewSingleDate = document.getElementById('viewSingleDate');
    
    if (viewStartDate) viewStartDate.value = formatDate(lastWeek);
    if (viewEndDate) viewEndDate.value = formatDate(today);
    if (viewSingleDate) viewSingleDate.value = formatDate(today);
    
    // Hide loading spinner
    document.getElementById('loading').style.display = 'none';
    
    console.log('📅 Default dates initialized');
});
