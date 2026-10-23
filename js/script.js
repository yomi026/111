
/* ========================================
   LITTLE PAWS — Interactive Features
   ======================================== */

document.addEventListener("DOMContentLoaded", () => {
  // 1. Update the copyright year.
  document.querySelectorAll(".current-year").forEach((element) => {
    element.textContent = new Date().getFullYear();
  });

  // 2. Mobile navigation.
  const menuToggle = document.querySelector(".menu-toggle");
  const navLinks = document.querySelector(".nav-links");

  if (menuToggle && navLinks) {
    const closeMenu = () => {
      navLinks.classList.remove("is-open");
      menuToggle.setAttribute("aria-expanded", "false");
      menuToggle.setAttribute("aria-label", "Open navigation menu");
    };

    menuToggle.addEventListener("click", () => {
      const isOpen = navLinks.classList.toggle("is-open");

      menuToggle.setAttribute("aria-expanded", String(isOpen));
      menuToggle.setAttribute(
        "aria-label",
        isOpen ? "Close navigation menu" : "Open navigation menu"
      );
    });

    navLinks.querySelectorAll("a").forEach((link) => {
      link.addEventListener("click", closeMenu);
    });

    document.addEventListener("keydown", (event) => {
      if (event.key === "Escape") {
        closeMenu();
        menuToggle.focus();
      }
    });

    document.addEventListener("click", (event) => {
      if (
        navLinks.classList.contains("is-open") &&
        !navLinks.contains(event.target) &&
        !menuToggle.contains(event.target)
      ) {
        closeMenu();
      }
    });
  }

  // 3. Animal category filters on animals.html.
  const animalFilters = document.querySelectorAll("[data-filter]");
  const animalCards = document.querySelectorAll("[data-animal]");
  const filterStatus = document.querySelector("#filter-status");
  const animalEmptyState = document.querySelector(
    ".animal-grid + .empty-state"
  );

  animalFilters.forEach((button) => {
    button.addEventListener("click", () => {
      const category = button.dataset.filter;
      let visibleCount = 0;

      animalFilters.forEach((filterButton) => {
        const selected = filterButton === button;

        filterButton.classList.toggle("active", selected);
        filterButton.setAttribute("aria-pressed", String(selected));
      });

      animalCards.forEach((card) => {
        const matches =
          category === "all" || card.dataset.animal === category;

        card.hidden = !matches;

        if (matches) {
          visibleCount += 1;
        }
      });

      if (animalEmptyState) {
        animalEmptyState.hidden = visibleCount > 0;
      }

      if (filterStatus) {
        filterStatus.textContent =
          category === "all"
            ? "Showing all animals."
            : `Showing ${visibleCount} ${category}${visibleCount === 1 ? "" : "s"}.`;
      }
    });
  });

  // 4. Gallery filters.
  const galleryFilters = document.querySelectorAll("[data-gallery-filter]");
  const galleryItems = document.querySelectorAll("[data-gallery-animal]");
  const galleryCount = document.querySelector("#gallery-count");
  const galleryEmptyState = document.querySelector(
    ".gallery-grid + .empty-state"
  );

  galleryFilters.forEach((button) => {
    button.addEventListener("click", () => {
      const category = button.dataset.galleryFilter;
      let visibleCount = 0;

      galleryFilters.forEach((filterButton) => {
        const selected = filterButton === button;

        filterButton.classList.toggle("active", selected);
        filterButton.setAttribute("aria-pressed", String(selected));
      });

      galleryItems.forEach((item) => {
        const matches =
          category === "all" ||
          item.dataset.galleryAnimal === category;

        item.hidden = !matches;

        if (matches) {
          visibleCount += 1;
        }
      });

      if (galleryCount) {
        galleryCount.textContent = `${visibleCount} lovely moments`;
      }

      if (galleryEmptyState) {
        galleryEmptyState.hidden = visibleCount > 0;
      }
    });
  });

  // 5. Favorite buttons on gallery.html.
  // Favorites are stored locally in this browser.
  const favoriteButtons = document.querySelectorAll(".favorite-button");
  const storageKey = "little-paws-favorites";

  let favorites = new Set();

  try {
    const saved = JSON.parse(localStorage.getItem(storageKey) || "[]");

    if (Array.isArray(saved)) {
      favorites = new Set(saved.filter((item) => typeof item === "string"));
    }
  } catch {
    favorites = new Set();
  }

  const updateFavoriteButton = (button, index) => {
    const isFavorite = favorites.has(String(index));

    button.setAttribute("aria-pressed", String(isFavorite));
    button.textContent = isFavorite ? "♥" : "♡";

    const animal = button
      .closest(".gallery-item")
      ?.dataset.galleryAnimal || "animal";

    button.setAttribute(
      "aria-label",
      `${isFavorite ? "Remove" : "Add"} ${animal} photo ${
        isFavorite ? "from" : "to"
      } favorites`
    );
  };

  favoriteButtons.forEach((button, index) => {
    updateFavoriteButton(button, index);

    button.addEventListener("click", () => {
      const key = String(index);

      if (favorites.has(key)) {
        favorites.delete(key);
      } else {
        favorites.add(key);
      }

      updateFavoriteButton(button, index);

      try {
        localStorage.setItem(
          storageKey,
          JSON.stringify([...favorites])
        );
      } catch {
        // The button still works for this page if storage is unavailable.
      }
    });
  });

  // 6. Random animal facts on gallery.html.
  const factButton = document.querySelector("#fact-button");
  const factText = document.querySelector("#fun-fact-text");

  const facts = [
    "Cats use their whiskers to help sense their surroundings.",
    "Dogs use their noses to explore a world full of scents.",
    "Rabbits need plenty of grass hay as part of a healthy diet.",
    "Hamsters are naturally active at different times, often around dusk and night.",
    "Every pet needs fresh water, a safe home, and gentle care.",
    "Positive, reward-based training can help dogs learn new skills.",
    "Cats benefit from safe places to climb, hide, scratch, and play."
  ];

  let previousFact = -1;

  if (factButton && factText) {
    factButton.addEventListener("click", () => {
      let nextFact = Math.floor(Math.random() * facts.length);

      // Avoid showing the same fact twice in a row.
      if (facts.length > 1) {
        while (nextFact === previousFact) {
          nextFact = Math.floor(Math.random() * facts.length);
        }
      }

      previousFact = nextFact;
      factText.textContent = facts[nextFact];
    });
  }
});
