// ============================================
// STUDENT DASHBOARD - COMPLETE FIXED VERSION
// ============================================

document.addEventListener('DOMContentLoaded', function () {
    console.log('✅ Student Dashboard Loaded');
    console.log('Student ID:', STUDENT_ID);
    console.log('Total Days:', TOTAL_DAYS);
    console.log('Present Days:', PRESENT_DAYS);
    console.log('Absent Days:', ABSENT_DAYS);

    // Initialize attendance chart
    initializeAttendanceChart();
    
    // Set current year automatically
    setCurrentYear();
    
    // Hide loading spinner
    const loadingSpinner = document.getElementById('loadingSpinner');
    if (loadingSpinner) {
        loadingSpinner.style.display = 'none';
    }
});

// ============================================
// SET CURRENT YEAR AUTOMATICALLY
// ============================================
function setCurrentYear() {
    const currentYear = new Date().getFullYear();
    const currentMonth = new Date().getMonth() + 1; // 1-12
    
    // Populate year dropdowns from (current-3) to (current+2)
    populateYearDropdown('reportYear', currentYear);
    populateYearDropdown('reportMonthYear', currentYear);
    
    // Set current month
    const reportMonth = document.getElementById('reportMonth');
    if (reportMonth) reportMonth.value = currentMonth;
    
    console.log('✅ Auto-set current year:', currentYear, 'month:', currentMonth);
}

// ============================================
// POPULATE YEAR DROPDOWN DYNAMICALLY
// ============================================
function populateYearDropdown(elementId, currentYear) {
    const dropdown = document.getElementById(elementId);
    if (!dropdown) return;
    
    // Clear existing options
    dropdown.innerHTML = '';
    
    // Add years: 3 years back to 2 years forward
    const startYear = currentYear - 3;
    const endYear = currentYear + 2;
    
    for (let year = startYear; year <= endYear; year++) {
        const option = document.createElement('option');
        option.value = year;
        option.textContent = year;
        if (year === currentYear) {
            option.selected = true;
        }
        dropdown.appendChild(option);
    }
    
    console.log(`✅ Populated ${elementId} with years ${startYear}-${endYear}, selected: ${currentYear}`);
}

// ============================================
// ATTENDANCE CHART INITIALIZATION
// ============================================
function initializeAttendanceChart() {
    const ctx = document.getElementById('attendanceChart');
    if (!ctx) return;

    if (TOTAL_DAYS > 0) {
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Present', 'Absent'],
                datasets: [{
                    data: [PRESENT_DAYS, ABSENT_DAYS],
                    backgroundColor: [
                        'rgba(6, 214, 160, 0.8)',
                        'rgba(239, 71, 111, 0.8)'
                    ],
                    borderColor: [
                        'rgba(6, 214, 160, 1)',
                        'rgba(239, 71, 111, 1)'
                    ],
                    borderWidth: 3,
                    hoverOffset: 10
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            font: { 
                                size: 14, 
                                weight: '600',
                                family: "'Segoe UI', sans-serif"
                            },
                            padding: 20,
                            usePointStyle: true
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function (context) {
                                const value = context.parsed || 0;
                                const percentage = ((value / TOTAL_DAYS) * 100).toFixed(1);
                                return context.label + ': ' + value + ' days (' + percentage + '%)';
                            }
                        },
                        backgroundColor: 'rgba(0, 0, 0, 0.8)',
                        padding: 12,
                        titleFont: { size: 14, weight: 'bold' },
                        bodyFont: { size: 13 }
                    }
                },
                cutout: '65%'
            }
        });
    } else {
        document.querySelector('.chart-card').innerHTML = `
            <div class="empty-state">
                <i class="fas fa-chart-pie"></i>
                <h5>No Data Available</h5>
                <p>Attendance chart will appear once your attendance is marked.</p>
            </div>`;
    }
}

// ============================================
// YEARLY REPORT GENERATION - FIXED
// ============================================
function generateYearlyReport() {
    const year = document.getElementById('reportYear').value;
    
    if (!year) {
        showAlert('warning', 'Please select a year');
        return;
    }
    
    console.log('📊 Generating yearly report for student:', STUDENT_ID, 'year:', year);
    
    showLoading(true);
    
    // FIXED: Using correct servlet path and action
    fetch(`StudentServlet?action=getYearlyReport&studentId=${STUDENT_ID}&year=${year}`)
        .then(response => {
            console.log('Response status:', response.status);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            showLoading(false);
            console.log('✅ Server response:', data);
            
            if (data.success && data.report) {
                displayYearlyReport(data.report, year);
            } else {
                document.getElementById('reportResults').innerHTML = `
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <h5>No Data Available</h5>
                        <p>No attendance records found for ${year}</p>
                    </div>`;
            }
        })
        .catch(error => {
            showLoading(false);
            console.error('❌ Error:', error);
            showAlert('danger', 'Failed to generate report: ' + error.message);
        });
}

// ============================================
// DISPLAY YEARLY REPORT
// ============================================
function displayYearlyReport(report, year) {
    const totalDays = report.totalDays || 0;
    const presentDays = report.presentDays || 0;
    const absentDays = report.absentDays || 0;
    const percentage = report.percentage || 0;
    
    const badgeClass = percentage >= 75 ? 'bg-success' : percentage >= 50 ? 'bg-warning' : 'bg-danger';
    
    let html = `
        <div class="report-summary">
            <h5 class="mb-4"><i class="fas fa-calendar-year"></i> Yearly Attendance Report - ${year}</h5>
            
            <div class="row g-3 mb-4">
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-calendar-alt"></i>
                        </div>
                        <div class="stat-value">${totalDays}</div>
                        <div class="stat-label">Total Days</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card present">
                        <div class="stat-icon">
                            <i class="fas fa-check-circle"></i>
                        </div>
                        <div class="stat-value" style="color: var(--success);">${presentDays}</div>
                        <div class="stat-label">Present Days</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card absent">
                        <div class="stat-icon">
                            <i class="fas fa-times-circle"></i>
                        </div>
                        <div class="stat-value" style="color: var(--danger);">${absentDays}</div>
                        <div class="stat-label">Absent Days</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-percentage"></i>
                        </div>
                        <div class="stat-value">${percentage}%</div>
                        <div class="stat-label">Attendance %</div>
                    </div>
                </div>
            </div>
            
            <div class="alert alert-${percentage >= 75 ? 'success' : percentage >= 50 ? 'warning' : 'danger'} mb-4">
                <i class="fas fa-info-circle"></i>
                <strong>Status:</strong> 
                ${percentage >= 75 ? 'Excellent attendance! Keep it up!' : 
                  percentage >= 50 ? 'Your attendance needs improvement.' : 
                  'Critical! Your attendance is below acceptable levels.'}
            </div>
            
            <div class="table-responsive">
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>Metric</th>
                            <th>Value</th>
                            <th>Percentage</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><i class="fas fa-calendar-check text-primary"></i> <strong>Total Days</strong></td>
                            <td><span class="badge bg-primary">${totalDays}</span></td>
                            <td>100%</td>
                        </tr>
                        <tr>
                            <td><i class="fas fa-check-circle text-success"></i> <strong>Present Days</strong></td>
                            <td><span class="badge bg-success">${presentDays}</span></td>
                            <td>${percentage}%</td>
                        </tr>
                        <tr>
                            <td><i class="fas fa-times-circle text-danger"></i> <strong>Absent Days</strong></td>
                            <td><span class="badge bg-danger">${absentDays}</span></td>
                            <td>${totalDays > 0 ? ((absentDays / totalDays) * 100).toFixed(1) : 0}%</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>`;
    
    document.getElementById('reportResults').innerHTML = html;
    
    showAlert('success', 'Yearly report generated successfully!');
}

// ============================================
// MONTHLY REPORT GENERATION - FIXED
// ============================================
function generateMonthlyReport() {
    const month = document.getElementById('reportMonth').value;
    const year = document.getElementById('reportMonthYear').value;
    
    if (!month || !year) {
        showAlert('warning', 'Please select month and year');
        return;
    }
    
    console.log('📊 Generating monthly report for student:', STUDENT_ID, 'month:', month, 'year:', year);
    
    showLoading(true);
    
    fetch(`StudentServlet?action=getMonthlyReport&studentId=${STUDENT_ID}&month=${month}&year=${year}`)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            showLoading(false);
            console.log('✅ Server response:', data);
            
            if (data.success && data.report) {
                displayMonthlyReport(data.report, month, year);
            } else {
                document.getElementById('reportResults').innerHTML = `
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <h5>No Data Available</h5>
                        <p>No attendance records found for the selected month</p>
                    </div>`;
            }
        })
        .catch(error => {
            showLoading(false);
            console.error('❌ Error:', error);
            showAlert('danger', 'Failed to generate report: ' + error.message);
        });
}

// ============================================
// DISPLAY MONTHLY REPORT
// ============================================
function displayMonthlyReport(report, month, year) {
    const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 
                       'July', 'August', 'September', 'October', 'November', 'December'];
    
    const totalDays = report.totalDays || 0;
    const presentDays = report.presentDays || 0;
    const absentDays = report.absentDays || 0;
    const percentage = report.percentage || 0;
    
    let html = `
        <div class="report-summary">
            <h5 class="mb-4"><i class="fas fa-calendar-alt"></i> Monthly Report - ${monthNames[parseInt(month) - 1]} ${year}</h5>
            
            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="stat-value">${totalDays}</div>
                        <div class="stat-label">Total Days</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card present">
                        <div class="stat-value" style="color: var(--success);">${presentDays}</div>
                        <div class="stat-label">Present Days</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card absent">
                        <div class="stat-value" style="color: var(--danger);">${absentDays}</div>
                        <div class="stat-label">Absent Days</div>
                    </div>
                </div>
            </div>
            
            <div class="progress" style="height: 30px; border-radius: 15px;">
                <div class="progress-bar bg-success" style="width: ${percentage}%">
                    ${percentage}% Present
                </div>
            </div>
        </div>`;
    
    document.getElementById('reportResults').innerHTML = html;
    showAlert('success', 'Monthly report generated!');
}

// ============================================
// EXPORT REPORT - FIXED
// ============================================
function exportReport() {
    const reportType = document.querySelector('input[name="reportType"]:checked')?.value;
    
    if (!reportType) {
        showAlert('warning', 'Please generate a report first');
        return;
    }
    
    console.log('📥 Exporting report type:', reportType);
    
    // Check if report is displayed
    const reportResults = document.getElementById('reportResults');
    if (!reportResults || reportResults.querySelector('.empty-state')) {
        showAlert('warning', 'Please generate the report first before exporting');
        return;
    }
    
    if (reportType === 'yearly') {
        exportYearlyReport();
    } else {
        exportMonthlyReport();
    }
}

function exportYearlyReport() {
    const year = document.getElementById('reportYear').value;
    
    showLoading(true);
    
    fetch(`StudentServlet?action=getYearlyReport&studentId=${STUDENT_ID}&year=${year}`)
        .then(response => response.json())
        .then(data => {
            showLoading(false);
            
            if (data.success && data.report) {
                const report = data.report;
                let csv = '\uFEFF'; // UTF-8 BOM
                csv += `Student Yearly Attendance Report - ${year}\n\n`;
                csv += `Student ID: ${STUDENT_ID}\n`;
                csv += `Report Date: ${new Date().toLocaleDateString()}\n\n`;
                csv += 'Metric,Value,Percentage\n';
                csv += `Total Days,${report.totalDays},100%\n`;
                csv += `Present Days,${report.presentDays},${report.percentage}%\n`;
                csv += `Absent Days,${report.absentDays},${report.totalDays > 0 ? ((report.absentDays / report.totalDays) * 100).toFixed(1) : 0}%\n`;
                
                downloadFile(csv, `Student_Attendance_Report_${year}.csv`, 'text/csv;charset=utf-8;');
                showAlert('success', 'Report exported successfully!');
            } else {
                showAlert('warning', 'No data available to export');
            }
        })
        .catch(error => {
            showLoading(false);
            console.error('Error:', error);
            showAlert('danger', 'Failed to export report');
        });
}

function exportMonthlyReport() {
    const month = document.getElementById('reportMonth').value;
    const year = document.getElementById('reportMonthYear').value;
    const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 
                       'July', 'August', 'September', 'October', 'November', 'December'];
    
    showLoading(true);
    
    fetch(`StudentServlet?action=getMonthlyReport&studentId=${STUDENT_ID}&month=${month}&year=${year}`)
        .then(response => response.json())
        .then(data => {
            showLoading(false);
            
            if (data.success && data.report) {
                const report = data.report;
                let csv = '\uFEFF'; // UTF-8 BOM
                csv += `Student Monthly Attendance Report - ${monthNames[parseInt(month) - 1]} ${year}\n\n`;
                csv += `Student ID: ${STUDENT_ID}\n`;
                csv += `Report Date: ${new Date().toLocaleDateString()}\n\n`;
                csv += 'Metric,Value,Percentage\n';
                csv += `Total Days,${report.totalDays},100%\n`;
                csv += `Present Days,${report.presentDays},${report.percentage}%\n`;
                csv += `Absent Days,${report.absentDays},${report.totalDays > 0 ? ((report.absentDays / report.totalDays) * 100).toFixed(1) : 0}%\n`;
                
                downloadFile(csv, `Student_Attendance_Report_${monthNames[parseInt(month) - 1]}_${year}.csv`, 'text/csv;charset=utf-8;');
                showAlert('success', 'Report exported successfully!');
            } else {
                showAlert('warning', 'No data available to export');
            }
        })
        .catch(error => {
            showLoading(false);
            console.error('Error:', error);
            showAlert('danger', 'Failed to export report');
        });
}

// ============================================
// TOGGLE REPORT TYPE
// ============================================
function toggleReportType() {
    const reportType = document.querySelector('input[name="reportType"]:checked').value;
    
    if (reportType === 'yearly') {
        document.getElementById('yearlyFilters').style.display = 'grid';
        document.getElementById('monthlyFilters').style.display = 'none';
    } else {
        document.getElementById('yearlyFilters').style.display = 'none';
        document.getElementById('monthlyFilters').style.display = 'grid';
    }
    
    document.getElementById('reportResults').innerHTML = `
        <div class="empty-state">
            <i class="fas fa-chart-bar"></i>
            <h5>Select Filters and Generate Report</h5>
            <p>Choose the appropriate filters and click "Generate Report"</p>
        </div>`;
}

// ============================================
// UTILITY FUNCTIONS
// ============================================
function showLoading(show) {
    const spinner = document.getElementById('loadingSpinner');
    if (spinner) {
        spinner.style.display = show ? 'flex' : 'none';
    }
}

function showAlert(type, message) {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
    alertDiv.style.position = 'fixed';
    alertDiv.style.top = '20px';
    alertDiv.style.right = '20px';
    alertDiv.style.zIndex = '10000';
    alertDiv.style.minWidth = '300px';
    alertDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    document.body.appendChild(alertDiv);
    
    setTimeout(() => {
        alertDiv.remove();
    }, 3000);
}

function downloadFile(content, filename, mimeType) {
    const blob = new Blob([content], { type: mimeType });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
}

// ============================================
// LOGOUT CONFIRMATION - BEAUTIFUL UI POPUP
// ============================================
function confirmLogout() {
    // Create custom modal overlay
    const modalHTML = `
        <div class="logout-modal-overlay" id="logoutModal" style="
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 99999;
            animation: fadeIn 0.3s;
        ">
            <div class="logout-modal-content" style="
                background: white;
                padding: 30px;
                border-radius: 15px;
                box-shadow: 0 10px 40px rgba(0,0,0,0.3);
                text-align: center;
                max-width: 400px;
                animation: slideIn 0.3s;
            ">
                <div style="
                    width: 80px;
                    height: 80px;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    margin: 0 auto 20px;
                ">
                    <i class="fas fa-sign-out-alt" style="font-size: 36px; color: white;"></i>
                </div>
                <h3 style="color: #333; margin-bottom: 10px; font-size: 24px;">Logout Confirmation</h3>
                <p style="color: #666; margin-bottom: 30px; font-size: 16px;">Are you sure you want to logout?</p>
                <div style="display: flex; gap: 15px; justify-content: center;">
                    <button onclick="closeLogoutModal()" style="
                        padding: 12px 30px;
                        background: #e0e0e0;
                        border: none;
                        border-radius: 8px;
                        cursor: pointer;
                        font-size: 16px;
                        font-weight: 600;
                        color: #333;
                        transition: all 0.3s;
                    " onmouseover="this.style.background='#d0d0d0'" onmouseout="this.style.background='#e0e0e0'">
                        <i class="fas fa-times"></i> Cancel
                    </button>
                    <button onclick="proceedLogout()" style="
                        padding: 12px 30px;
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        border: none;
                        border-radius: 8px;
                        cursor: pointer;
                        font-size: 16px;
                        font-weight: 600;
                        color: white;
                        transition: all 0.3s;
                    " onmouseover="this.style.transform='scale(1.05)'" onmouseout="this.style.transform='scale(1)'">
                        <i class="fas fa-check"></i> Yes, Logout
                    </button>
                </div>
            </div>
        </div>
        <style>
            @keyframes fadeIn {
                from { opacity: 0; }
                to { opacity: 1; }
            }
            @keyframes slideIn {
                from { transform: translateY(-50px); opacity: 0; }
                to { transform: translateY(0); opacity: 1; }
            }
        </style>
    `;
    
    document.body.insertAdjacentHTML('beforeend', modalHTML);
}

function closeLogoutModal() {
    const modal = document.getElementById('logoutModal');
    if (modal) {
        modal.style.animation = 'fadeOut 0.3s';
        setTimeout(() => modal.remove(), 300);
    }
}

function proceedLogout() {
    window.location.href = 'login?action=logout';
}