const pageCursor = document.querySelector("[data-page-cursor]");

const cursorImages = [
  "./assets/burek-cursor.png",
  "./assets/burek-cursor-cheese-stack.png",
  "./assets/burek-cursor-rolled-plate.png",
  "./assets/burek-cursor-folded-meat.png",
];

if (pageCursor && window.matchMedia("(pointer: fine)").matches) {
  let activeCursor = 0;
  let nextX = -200;
  let nextY = -200;
  let animationFrame = 0;
  let floatingAnimationStart = 0;
  let lastRegisteredClick = 0;

  cursorImages.forEach((src) => {
    const image = new Image();
    image.src = src;
  });

  const positionCursor = (timestamp) => {
    if (floatingAnimationStart === 0) {
      floatingAnimationStart = timestamp;
    }

    const elapsed = (timestamp - floatingAnimationStart) / 1000;
    const phase = elapsed * 2 * Math.PI / 1.35;
    const floatX = Math.cos(phase * 0.7) * 3;
    const floatY = Math.sin(phase) * 6;

    pageCursor.style.transform = `translate3d(${nextX + 8 + floatX}px, ${nextY + 8 - floatY}px, 0)`;
    animationFrame = window.requestAnimationFrame(positionCursor);
  };

  const startFloating = () => {
    if (animationFrame === 0) {
      animationFrame = window.requestAnimationFrame(positionCursor);
    }
  };

  const stopFloating = () => {
    if (animationFrame !== 0) {
      window.cancelAnimationFrame(animationFrame);
      animationFrame = 0;
    }
  };

  window.addEventListener("pointermove", (event) => {
    nextX = event.clientX;
    nextY = event.clientY;
    pageCursor.classList.add("is-visible");
    startFloating();
  });

  window.addEventListener("pointerdown", () => {
    const now = performance.now();
    if (now - lastRegisteredClick <= 40) {
      return;
    }

    lastRegisteredClick = now;
    activeCursor = (activeCursor + 1) % cursorImages.length;
    pageCursor.src = cursorImages[activeCursor];
  });

  document.addEventListener("mouseleave", () => {
    pageCursor.classList.remove("is-visible");
    stopFloating();
  });
}
