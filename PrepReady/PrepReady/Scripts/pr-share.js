/* EX-13: client-side social sharing (LinkedIn / X / WhatsApp / Copy link).
   No external SDKs — just standard share-intent URLs opened in a popup window.
   A .pr-share wrapper supplies the target via data-* attributes:
     data-url="self"                        -> share the current page URL
     data-code + data-verify (app path)     -> build origin + /Verify.aspx?code=CODE
     data-text                              -> the message used by X / WhatsApp
   Buttons inside carry class="pr-share-go" and data-net="linkedin|x|whatsapp|copy". */
(function () {
    "use strict";

    function shareUrlFor(wrap) {
        var direct = wrap.getAttribute("data-url");
        if (direct && direct !== "self") return direct;

        var code = wrap.getAttribute("data-code");
        var base = wrap.getAttribute("data-verify");
        if (code && base) {
            return window.location.origin + base + "?code=" + encodeURIComponent(code);
        }
        return window.location.href;
    }

    function shareTextFor(wrap) {
        return wrap.getAttribute("data-text") ||
            "Verified on the PrepReady National Recognised Responders Registry.";
    }

    function openIntent(net, url, text) {
        var u = encodeURIComponent(url);
        var t = encodeURIComponent(text);
        var target = null;

        if (net === "linkedin") {
            target = "https://www.linkedin.com/sharing/share-offsite/?url=" + u;
        } else if (net === "x") {
            target = "https://twitter.com/intent/tweet?text=" + t + "&url=" + u;
        } else if (net === "whatsapp") {
            target = "https://wa.me/?text=" + encodeURIComponent(text + " " + url);
        }
        if (target) {
            window.open(target, "_blank", "noopener,noreferrer,width=640,height=640");
        }
    }

    function flash(wrap, msg) {
        var fb = wrap.querySelector(".pr-share-feedback");
        if (!fb) return;
        fb.textContent = msg;
        window.setTimeout(function () { fb.textContent = ""; }, 1800);
    }

    function copyLink(wrap, url) {
        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(url).then(
                function () { flash(wrap, "Link copied!"); },
                function () { legacyCopy(wrap, url); }
            );
        } else {
            legacyCopy(wrap, url);
        }
    }

    function legacyCopy(wrap, url) {
        try {
            var ta = document.createElement("textarea");
            ta.value = url;
            ta.style.position = "fixed";
            ta.style.opacity = "0";
            document.body.appendChild(ta);
            ta.focus();
            ta.select();
            document.execCommand("copy");
            document.body.removeChild(ta);
            flash(wrap, "Link copied!");
        } catch (e) {
            flash(wrap, "Press Ctrl+C to copy");
        }
    }

    document.addEventListener("click", function (e) {
        var btn = e.target.closest ? e.target.closest(".pr-share-go") : null;
        if (!btn) return;
        e.preventDefault();

        var wrap = btn.closest(".pr-share") || btn;
        var net = btn.getAttribute("data-net");
        var url = shareUrlFor(wrap);

        if (net === "copy") {
            copyLink(wrap, url);
        } else {
            openIntent(net, url, shareTextFor(wrap));
        }
    });
})();