# sage_setup: distribution = sagemath-repl
"""
Marimo backend for the Sage Rich Output System

This module defines the Marimo backend for
:mod:`sage.repl.rich_output`.
"""

# ****************************************************************************
#       Copyright (C) 2026 Shahzeb Imran <s.imran@tuta.io>
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 2 of
#  the License, or (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

import base64
import html
import marimo as mo
from marimo._output import formatting
from sage.repl.rich_output.preferences import DisplayPreferences
from sage.repl.rich_output.backend_base import BackendBase
from sage.repl.rich_output import get_display_manager  # type: ignore
from sage.repl.rich_output.output_basic import OutputBase
from sage.repl.rich_output.output_catalog import (
    OutputAsciiArt,
    OutputHtml,
    OutputImagePng,
    OutputImageJpg,
    OutputImageGif,
    OutputImageSvg,
    OutputLatex,
    OutputPlainText,
    OutputSceneThreejs,
    OutputUnicodeArt,
)
from typing import Any


class BackendMarimo(BackendBase):
    """
    Marimo backend

    EXAMPLES::

        # in a marimo notebook

        sage: from sage.repl.rich_output.backend_marimo import BackendMarimo
        sage: from sage.repl.rich_output import get_display_manager
        sage: dm = get_display_manager()
        sage: dm.switch_backend(BackendMarimo())
        sage: print(dm.get_instance())
        The Sage display manager using the Marimo Notebook backend

        sage: print(dm.preferences())
        Display preferences:
        * align_latex = center
        * graphics is not specified
        * supplemental_plot is not specified
        * text = latex
    """

    _SUPPORTED_OUTPUT_CLASSES = (
        OutputPlainText,
        OutputAsciiArt,
        OutputUnicodeArt,
        OutputHtml,
        OutputImagePng,
        OutputImageJpg,
        OutputImageGif,
        OutputImageSvg,
        OutputSceneThreejs,
        OutputLatex,
    )

    def _repr_(self) -> str:
        return "Marimo Notebook"

    def install(self) -> None:
        from sage.structure.sage_object import SageObject

        # register formatters with marimo
        @formatting.formatter(SageObject)
        def _show_sage_object(sobj: SageObject) -> tuple[str, str]:
            """
            handles cases where we have a SageObject and we have to get the rich_output
            before rendering it
            """
            plain_text, rich_output = get_display_manager()._rich_output_formatter(
                sobj, dict()
            )
            return self._render_rich_output(rich_output, fallback_obj=sobj)

        def _show_output_base(obj: OutputBase) -> tuple[str, str]:
            """
            handles cases where we already have the rich_output
            e.g. when .show() is invoked and we register the output through
            a call to display_immediately
            """
            return self._render_rich_output(obj)

        for cls in self._SUPPORTED_OUTPUT_CLASSES:
            formatting.formatter(cls)(_show_output_base)

    def default_preferences(self) -> DisplayPreferences:
        return DisplayPreferences(text="latex", align_latex="center")

    def supported_output(self) -> set:
        return set(self._SUPPORTED_OUTPUT_CLASSES)

    def _format_html_image(self, image_format: str, image: bytes) -> tuple[str, str]:
        b64 = base64.b64encode(image).decode("ascii")

        img_html = f"""
       <div style="resize: vertical; overflow: hidden; width: 100%; display: flex; align-items: center; justify-content: center;">
           <img src="data:image/{image_format}; base64,{b64}" 
                style="max-width: 100%; max-height: 100%; object-fit: contain;" />
       </div>
       """

        return ("text/html", img_html)

    def _render_rich_output(
        self, rich_output: OutputBase, fallback_obj: Any = None
    ) -> tuple[str, str]:
        match rich_output:
            case OutputHtml():
                html_str = rich_output.html.get_str()
                # the default sage latex formatter outputs latex with <html> tags
                # we strip them if present
                if html_str.startswith("<html>") and html_str.endswith("</html>"):
                    html_str = html_str[len("<html>") : -len("</html>")]
                return (
                    "text/html",
                    mo.md(f"""{html_str}""").text,
                )
            # we wrap graphics outputs in a div to allow resizing
            case OutputSceneThreejs():
                escaped_html = html.escape(rich_output.html.get_str())

                iframe = f"""
                <div style="resize: vertical; overflow: hidden; width: 100%; min-width: 100%; max-width: 100%; position: relative; min-height: 150px;">
                    <iframe srcdoc="{escaped_html}"
                            style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0;">
                    </iframe>
                </div>
                """
                return ("text/html", iframe)

            case OutputImagePng():
                return self._format_html_image("png", rich_output.png.get())

            case OutputImageJpg():
                return self._format_html_image("jpg", rich_output.jpg.get())

            case OutputImageGif():
                return self._format_html_image("gif", rich_output.gif.get())

            case OutputImageSvg():
                svg_str = rich_output.svg.get_str()

                svg_html = f"""
                <div class="resizable-svg-wrapper" style="resize: vertical; overflow: hidden; width: 100%; display: flex; align-items: center; justify-content: center;">
                    <style>
                        .resizable-svg-wrapper > svg {{
                            max-width: 100% !important;
                            max-height: 100% !important;
                            height: auto !important;
                            object-fit: contain !important;
                        }}
                    </style>
                    {svg_str}
                </div>
                """
                return ("text/html", svg_html)

            # since we have OutputHtml enabled, the sage output formatter automatically
            # outputs rich output as MathJax HTML.
            # This one is for raw latex output
            case OutputLatex():
                return (
                    "text/html",
                    mo.md(f"""\\[{rich_output.latex.get_str()}\\]""").text,
                )

            case OutputAsciiArt():
                return (
                    "text/html",
                    f"<pre>{html.escape(rich_output.ascii_art.get_str())}</pre>",
                )

            case OutputUnicodeArt():
                return (
                    "text/html",
                    f"<pre>{html.escape(rich_output.unicode_art.get_str())}</pre>",
                )

            case OutputPlainText():
                return ("text/plain", rich_output.text.get_str())

        # fallback: try latex output first and if that fails, plaintext
        if fallback_obj is not None:
            try:
                return (
                    "text/html",
                    mo.md(f"""\\[{fallback_obj._latex_()}\\]""").text,
                )
            except (AttributeError, TypeError):
                return ("text/plain", repr(fallback_obj))

        return ("text/plain", repr(rich_output))

    def display_immediately(
        self, plain_text: OutputPlainText, rich_output: OutputBase
    ) -> None:
        mo.output.append(rich_output)

    def threejs_offline_scripts(self) -> str:
        return get_display_manager().threejs_scripts(online=True)
