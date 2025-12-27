// ========================================
// EDUTRACK PRO - ENHANCED JAVASCRIPT
// ========================================

// Navbar scroll effect with smooth transition
window.addEventListener('scroll', function() {
    const navbar = document.querySelector('.navbar');
    if (navbar) {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    }
});

// Smooth scrolling for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
        const targetId = this.getAttribute('href');
        if (targetId === '#') return;
        
        e.preventDefault();
        const targetElement = document.querySelector(targetId);
        if (targetElement) {
            const navbarHeight = document.querySelector('.navbar')?.offsetHeight || 80;
            window.scrollTo({
                top: targetElement.offsetTop - navbarHeight,
                behavior: 'smooth'
            });
        }
    });
});

// Hero title word-by-word animation
document.addEventListener('DOMContentLoaded', function() {
    const heroTitle = document.querySelector('.hero-title');
    if (heroTitle && !heroTitle.classList.contains('animate__animated')) {
        const text = heroTitle.textContent;
        const words = text.split(' ');
        heroTitle.innerHTML = '';
        
        words.forEach((word, index) => {
            const span = document.createElement('span');
            span.className = 'word';
            span.textContent = word + ' ';
            span.style.animationDelay = `${index * 0.15}s`;
            heroTitle.appendChild(span);
        });
    }
});

// ========================================
// SCROLL REVEAL ANIMATIONS
// ========================================

// Add scroll reveal styles dynamically
const revealStyle = document.createElement('style');
revealStyle.textContent = `
    .scroll-reveal {
        opacity: 0;
        transform: translateY(40px);
        transition: all 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94);
    }
    
    .scroll-reveal.revealed {
        opacity: 1;
        transform: translateY(0);
    }
    
    @keyframes ripple {
        to {
            transform: scale(100);
            opacity: 0;
        }
    }
    
    .feature-card.clicked {
        animation: cardPulse 0.6s ease;
    }
    
    @keyframes cardPulse {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.05); }
    }
`;
document.head.appendChild(revealStyle);

// Intersection Observer for scroll reveal
const revealElements = document.querySelectorAll(
    '.about-card, .feature-card, .about-text, .about-list, .cta-section'
);

const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry, index) => {
        if (entry.isIntersecting) {
            setTimeout(() => {
                entry.target.classList.add('revealed');
            }, index * 100);
        }
    });
}, {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
});

revealElements.forEach(el => {
    el.classList.add('scroll-reveal');
    revealObserver.observe(el);
});

// ========================================
// FEATURE CARD INTERACTIONS
// ========================================

document.querySelectorAll('.feature-card').forEach(card => {
    // Click animation with ripple effect
    card.addEventListener('click', function(e) {
        // Remove clicked class from all cards
        document.querySelectorAll('.feature-card').forEach(c => {
            c.classList.remove('clicked');
        });
        
        // Add clicked class to current card
        this.classList.add('clicked');
        
        // Create ripple effect
        const ripple = document.createElement('div');
        const rect = this.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);
        
        ripple.style.position = 'absolute';
        ripple.style.width = '10px';
        ripple.style.height = '10px';
        ripple.style.background = 'rgba(67, 97, 238, 0.3)';
        ripple.style.borderRadius = '50%';
        ripple.style.transform = 'scale(0)';
        ripple.style.animation = 'ripple 0.6s ease-out';
        ripple.style.pointerEvents = 'none';
        ripple.style.zIndex = '10';
        
        // Position ripple at click location
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        ripple.style.left = x + 'px';
        ripple.style.top = y + 'px';
        ripple.style.marginLeft = '-5px';
        ripple.style.marginTop = '-5px';
        
        this.style.position = 'relative';
        this.appendChild(ripple);
        
        // Remove ripple and clicked class after animation
        setTimeout(() => {
            ripple.remove();
            this.classList.remove('clicked');
        }, 600);
    });
    
    // Enhanced hover effect
    card.addEventListener('mouseenter', function() {
        this.style.transition = 'all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)';
    });
    
    card.addEventListener('mouseleave', function() {
        this.style.transition = 'all 0.4s ease';
    });
});

// ========================================
// PARALLAX EFFECT FOR HERO SECTION
// ========================================

let ticking = false;
window.addEventListener('scroll', function() {
    if (!ticking) {
        window.requestAnimationFrame(function() {
            const scrolled = window.pageYOffset;
            const heroSection = document.querySelector('.hero-section');
            
            if (heroSection && scrolled < window.innerHeight) {
                // Parallax effect
                const parallaxSpeed = 0.3;
                heroSection.style.transform = `translateY(${scrolled * parallaxSpeed}px)`;
                
                // Fade out effect
                const opacity = 1 - (scrolled / window.innerHeight) * 0.5;
                heroSection.style.opacity = Math.max(opacity, 0.5);
            }
            
            ticking = false;
        });
        ticking = true;
    }
});

// ========================================
// ANIMATED COUNTER FOR STATS
// ========================================

function animateValue(element, start, end, duration) {
    let startTimestamp = null;
    const step = (timestamp) => {
        if (!startTimestamp) startTimestamp = timestamp;
        const progress = Math.min((timestamp - startTimestamp) / duration, 1);
        const value = Math.floor(progress * (end - start) + start);
        
        // Format number with commas
        const formattedValue = value.toLocaleString();
        element.textContent = formattedValue + (element.dataset.suffix || '');
        
        if (progress < 1) {
            window.requestAnimationFrame(step);
        }
    };
    window.requestAnimationFrame(step);
}

// Observe stat cards for animation
const statObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const target = entry.target.querySelector('.stat-number');
            if (target && !target.classList.contains('animated')) {
                const endValue = parseInt(target.dataset.value || target.textContent.replace(/,/g, ''));
                target.classList.add('animated');
                animateValue(target, 0, endValue, 2000);
            }
        }
    });
}, { threshold: 0.5 });

document.querySelectorAll('.stat-card').forEach(card => {
    statObserver.observe(card);
});

// ========================================
// MOBILE MENU ENHANCEMENTS
// ========================================

const navbarToggler = document.querySelector('.navbar-toggler');
const navbarCollapse = document.querySelector('.navbar-collapse');

if (navbarToggler && navbarCollapse) {
    // Close mobile menu when clicking on a link
    document.querySelectorAll('.navbar-nav .nav-link').forEach(link => {
        link.addEventListener('click', function() {
            if (window.innerWidth < 992) {
                const bsCollapse = new bootstrap.Collapse(navbarCollapse, {
                    toggle: false
                });
                bsCollapse.hide();
            }
        });
    });
}

// ========================================
// LOADING ANIMATION
// ========================================

window.addEventListener('load', function() {
    document.body.classList.add('loaded');
    
    // Add a subtle entrance animation to main sections
    const mainSections = document.querySelectorAll('section');
    mainSections.forEach((section, index) => {
        section.style.opacity = '0';
        section.style.transform = 'translateY(20px)';
        section.style.transition = 'all 0.6s ease';
        
        setTimeout(() => {
            section.style.opacity = '1';
            section.style.transform = 'translateY(0)';
        }, index * 100);
    });
});

// ========================================
// ENHANCED ABOUT CARD ANIMATIONS
// ========================================

document.querySelectorAll('.about-card').forEach(card => {
    card.addEventListener('mouseenter', function() {
        // Slight rotation on hover
        this.style.transform = 'translateY(-12px) rotateX(5deg)';
    });
    
    card.addEventListener('mouseleave', function() {
        this.style.transform = 'translateY(0) rotateX(0)';
    });
});

// ========================================
// SOCIAL ICON INTERACTIONS
// ========================================

document.querySelectorAll('.social-icon').forEach(icon => {
    icon.addEventListener('mouseenter', function() {
        this.style.transform = 'translateY(-5px) scale(1.1)';
    });
    
    icon.addEventListener('mouseleave', function() {
        this.style.transform = 'translateY(0) scale(1)';
    });
});

// ========================================
// PERFORMANCE OPTIMIZATION
// ========================================

// Debounce function for scroll events
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// ========================================
// ACCESSIBILITY ENHANCEMENTS
// ========================================

// Add keyboard navigation for cards
document.querySelectorAll('.feature-card, .about-card').forEach(card => {
    card.setAttribute('tabindex', '0');
    
    card.addEventListener('keypress', function(e) {
        if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            this.click();
        }
    });
});

// ========================================
// CONSOLE WELCOME MESSAGE
// ========================================

console.log('%c🎓 EduTrack Pro', 'color: #4361ee; font-size: 24px; font-weight: bold;');
console.log('%cStudent Attendance Management System', 'color: #7209b7; font-size: 14px;');
console.log('%cVersion 1.0.0 | Powered by Modern Web Technologies', 'color: #6c757d; font-size: 12px;');