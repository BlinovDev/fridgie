import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["input", "tags", "hidden"];
    static values = {
        initialProducts: { type: Array, default: [] },
        max: { type: Number, default: 10 },
        maxLen: { type: Number, default: 50 },
    };

    // Called before connect() and before any action methods.
    // Used here to initialize the products array so it's always defined.
    initialize() {
        this.products = [];
    }

    // Called when the controller is connected to the DOM.
    // Restores products from the initial data attribute and renders them.
    connect() {
        if (Array.isArray(this.initialProductsValue)) {
            this.initialProductsValue.forEach((p) => this._tryAddTag(p));
            this._render();
        }
    }

    // Handles the Enter key inside the input.
    // Prevents default submit, adds the current value as a product,
    // and then triggers the form submission programmatically.
    enterPressed(event) {
        event.preventDefault();
        this._addFromInput();
        this.element.requestSubmit();
    }

    // Handles the form's submit event.
    // Ensures any text in the input is added as a product before sending,
    // and syncs hidden fields so they match the current products array.
    onSubmit() {
        this._addFromInput();
        this._syncHiddenInputs();
    }

    // Removes a product by its index when the remove button is clicked,
    // re-renders the list, syncs hidden inputs, and submits the form immediately.
    removeTag(event) {
        const idx = Number(event.currentTarget?.dataset?.index);
        if (Number.isInteger(idx)) {
            this.products.splice(idx, 1);
            this._render();
            this.element.requestSubmit(); // immediately submit the form
        }
    }

    // === Internal helper methods ===

    // Reads the current input value, tries to add it as a tag,
    // clears the input if successful, and re-renders the tags.
    _addFromInput() {
        const raw = this.inputTarget.value;
        const added = this._tryAddTag(raw);
        if (added) {
            this.inputTarget.value = "";
            this._render();
        }
        return added;
    }

    // Attempts to add a tag to the products array.
    // Trims whitespace, validates length, checks for duplicates,
    // and enforces the max tag limit.
    _tryAddTag(raw) {
        if (!Array.isArray(this.products)) this.products = [];
        if (typeof raw !== "string") return false;

        const tag = raw.trim();
        if (!tag) return false;
        if (tag.length > this.maxLenValue) return false;

        const lower = tag.toLowerCase();
        if (this.products.map((t) => t.toLowerCase()).includes(lower)) return false;
        if (this.products.length >= this.maxValue) return false;

        this.products.push(tag);
        return true;
    }

    // Renders the current list of products as Bootstrap badges
    // with a remove button for each, and syncs the hidden inputs.
    _render() {
        this.tagsTarget.innerHTML = "";
        this.products.forEach((tag, idx) => {
            const chip = document.createElement("span");
            chip.className = "badge bg-secondary me-2 mb-2";
            chip.textContent = tag;

            const btn = document.createElement("button");
            btn.type = "button";
            btn.className = "btn-close btn-close-white btn-close-sm ms-2 align-middle";
            btn.setAttribute("aria-label", "Remove");
            btn.dataset.index = String(idx);
            btn.addEventListener("click", this.removeTag.bind(this));

            chip.appendChild(btn);
            this.tagsTarget.appendChild(chip);
        });

        this._syncHiddenInputs();
    }

    // Synchronizes the hidden input fields with the current products array
    // so that all products are submitted with the form as products[].
    _syncHiddenInputs() {
        this.hiddenTarget.innerHTML = "";
        this.products.forEach((tag) => {
            const input = document.createElement("input");
            input.type = "hidden";
            input.name = "products[]";
            input.value = tag;
            this.hiddenTarget.appendChild(input);
        });
    }
}
