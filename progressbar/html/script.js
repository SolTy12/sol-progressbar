let progressTimer = null;
let startTime = 0;
let totalDuration = 0;

window.addEventListener('message', (event) => {
    if (event.data.action === "start") {
        totalDuration = event.data.duration;
        document.getElementById('progress-maintitle').innerText = event.data.label;
        document.getElementById('progress-container').classList.remove('hidden');
        
        startTime = Date.now();
        
        if (progressTimer) cancelAnimationFrame(progressTimer);
        
        const updateProgress = () => {
            const elapsed = Date.now() - startTime;
            let percentage = Math.floor((elapsed / totalDuration) * 100);
            
            if (percentage >= 100) {
                percentage = 100;
            } else {
                progressTimer = requestAnimationFrame(updateProgress);
            }
            
            const dots = ['.', '..', '...'];
            const dotIndex = Math.floor((elapsed / 400)) % 3;
            
            document.getElementById('progress-percentage').innerText = dots[dotIndex];
            document.getElementById('progress-fill').style.width = percentage + '%';
            
            if (percentage === 100) {
                setTimeout(() => {
                    document.getElementById('progress-container').classList.add('hidden');
                }, 100);
            }
        };
        
        progressTimer = requestAnimationFrame(updateProgress);
    } else if (event.data.action === "cancel") {
        if (progressTimer) cancelAnimationFrame(progressTimer);
        document.getElementById('progress-container').classList.add('hidden');
    }
});
