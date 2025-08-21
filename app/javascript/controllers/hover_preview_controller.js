import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["template"];
    static values = {
        delay: { type: Number, default: 1500 },
        offsetX: { type: Number, default: 12 },
        offsetY: { type: Number, default: 12 }
    }

    connect() {
        this.timer = null;
        this.panel = null;
        this.boundReposition = this.reposition.bind(this);
        this.boundHide = this.leave.bind(this);
    }

    enter(event) {
        if (window.matchMedia("(pointer: coarse)").matches) return;

        if (this.timer) clearTimeout(this.timer);
        this.timer = setTimeout(() => this.show(), this.delayValue);

        window.addEventListener("scroll", this.boundHide, { passive: true });
        window.addEventListener("resize", this.boundReposition, { passive: true });
    }

    leave() {
        if (this.timer) {
            clearTimeout(this.timer);
            this.timer = null;
        }
        this.hide();
        window.removeEventListener("scroll", this.boundHide);
        window.removeEventListener("resize", this.boundReposition);
    }

    show() {
        if (!this.hasTemplateTarget) return;

        if (!this.panel) {
            this.panel = document.createElement("div");
            this.panel.className = "recipe-mini-modal";

            const tpl = this.templateTarget.content
                ? this.templateTarget.content.cloneNode(true)
                : this.templateTarget.cloneNode(true);
            this.panel.appendChild(tpl);
            document.body.appendChild(this.panel);
        }

        this.reposition();
        this.panel.classList.add("show");
    }

    hide() {
        if (this.panel) {
            this.panel.classList.remove("show");

            setTimeout(() => {
                if (this.panel && this.panel.parentNode) {
                    this.panel.parentNode.removeChild(this.panel);
                }
                this.panel = null;
            }, 100);
        }
    }

    reposition() {
        if (!this.panel) return;

        const cardRect = this.element.getBoundingClientRect();
        const panelRect = this.panel.getBoundingClientRect();

        let left = window.scrollX + cardRect.right + this.offsetXValue;
        let top = window.scrollY + cardRect.top + this.offsetYValue;

        if (left + panelRect.width > window.scrollX + window.innerWidth - 8) {
            left = window.scrollX + cardRect.left - panelRect.width - this.offsetXValue;
        }
        if (top + panelRect.height > window.scrollY + window.innerHeight - 8) {
            top = window.scrollY + window.innerHeight - panelRect.height - 8;
        }
        if (top < window.scrollY + 8) top = window.scrollY + 8;

        this.panel.style.left = `${left}px`;
        this.panel.style.top = `${top}px`;
    }
}
