define(['notebook/js/codecell', 'notebook/js/outputarea'], function(codecell_mod, oa_mod){
    return {'onload': function(){
        codecell_mod.CodeCell.prototype.input_prompt_function = function (prompt_value, lines_number) {
                return 'gp>';
            };

        oa_mod.OutputArea.prototype.append_execute_result = function (json) {
            var n = json.execution_count || ' ';
            var toinsert = this.create_output_area();
            if (this.prompt_area) {
                toinsert.find('div.prompt').addClass('output_prompt').text('%' + n + ' =');
            }
            var inserted = this.append_mime_type(json, toinsert);
            if (inserted) {
                inserted.addClass('output_result');
            }
            this._safe_append(toinsert);
            // If we just output latex, typeset it.
            if ((json.data['text/latex'] !== undefined) ||
                (json.data['text/html'] !== undefined) ||
                (json.data['text/markdown'] !== undefined)) {
                this.typeset();
            }
        };

    }}
})

