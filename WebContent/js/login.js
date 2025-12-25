// Password visibility toggle
document.getElementById('togglePassword').addEventListener('click', function() {
    const passwordInput = document.getElementById('password');
    const icon = this.querySelector('i');
    
    if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        icon.classList.remove('fa-eye');
        icon.classList.add('fa-eye-slash');
        this.title = "Hide password";
    } else {
        passwordInput.type = 'password';
        icon.classList.remove('fa-eye-slash');
        icon.classList.add('fa-eye');
        this.title = "Show password";
    }
});

// Role selection
// Role selection
const roleOptions = document.querySelectorAll('.role-option');
const formRoleInput = document.getElementById('formRole');
const selectedRoleInput = document.getElementById('selectedRole');

// Preselect role (value comes from JSP)
if (typeof PRESELECTED_ROLE !== "undefined" && PRESELECTED_ROLE !== "") {
    roleOptions.forEach(opt => {
        if (opt.getAttribute('data-role') === PRESELECTED_ROLE) {
            roleOptions.forEach(o => o.classList.remove('active'));
            opt.classList.add('active');
            formRoleInput.value = PRESELECTED_ROLE;
            selectedRoleInput.value = PRESELECTED_ROLE;
        }
    });
}


roleOptions.forEach(option => {
    option.addEventListener('click', function() {
        roleOptions.forEach(opt => opt.classList.remove('active'));
        this.classList.add('active');
        
        const role = this.getAttribute('data-role');
        formRoleInput.value = role;
        selectedRoleInput.value = role;
        
        const usernameInput = document.getElementById('username');
        if (role === 'student') {
            usernameInput.placeholder = "Enter your student ID or email";
        } else if (role === 'teacher') {
            usernameInput.placeholder = "Enter your teacher ID or email";
        } else if (role === 'admin') {
            usernameInput.placeholder = "Enter your administrator username";
        }
    });
});

// Auto-focus username on page load
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('username').focus();
});