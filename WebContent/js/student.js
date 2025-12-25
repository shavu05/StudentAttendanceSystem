document.addEventListener('DOMContentLoaded', function () {
    console.log('✅ Student Dashboard Loaded');

    console.log('Student ID:', STUDENT_ID);
    console.log('Total Days:', TOTAL_DAYS);
    console.log('Present Days:', PRESENT_DAYS);
    console.log('Absent Days:', ABSENT_DAYS);

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
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            font: { size: 14, weight: '600' },
                            padding: 20
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function (context) {
                                const value = context.parsed || 0;
                                const percentage = ((value / TOTAL_DAYS) * 100).toFixed(1);
                                return context.label + ': ' + value + ' days (' + percentage + '%)';
                            }
                        }
                    }
                }
            }
        });
    } else {
        document.querySelector('.chart-card').innerHTML =
            '<div class="empty-state">' +
            '<i class="fas fa-chart-pie"></i>' +
            '<h5>No Data Available</h5>' +
            '<p>Attendance chart will appear once your attendance is marked.</p>' +
            '</div>';
    }
});

// Logout confirmation
function confirmLogout() {
    if (confirm('Are you sure you want to logout?')) {
        window.location.href = 'login?action=logout';
    }
}
