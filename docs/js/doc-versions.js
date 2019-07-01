/* When the user clicks on the navigation Documentation button,
 * toggle between hiding and showing the dropdown content.
 */
function displayToggle(e) {
  e.preventDefault();
  e.stopPropagation();
  const dropdown = document.querySelector("#version-dropdown > .dropdown-content");
  dropdown.classList.toggle("show");
  if (dropdown.classList.contains("show")) {
    window.addEventListener("click", closeDropdown);
  }
  else {
    window.removeEventListener("click", closeDropdown);
  }
}

// Close the dropdown if the user clicks outside of it
function closeDropdown(e) {
  const dropdown = document.querySelector("#version-dropdown > .dropdown-content");
  const relatedTarget = e.relatedTarget || {};
  if (relatedTarget.parentNode !== dropdown) dropdown.classList.remove("show");
  window.removeEventListener("click", closeDropdown);
}
