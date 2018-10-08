dojo_style_prefix = ['dojo.setAttr(dojo.query("[class=''mwListItem'']")[10],'];
win.executeJS([dojo_style_prefix '"after","<span>*</span>")']);
dojo_style_prefix = ['dojo.style(dojo.query("[class=''mwListItem'']")[10],'];
win.executeJS([dojo_style_prefix '"color","red")']);


or = chanlabels(app.D{1},app.order(~isnan(app.order)));
[win, widgetID] = mlapptools.getWebElements(app.listbox1);
for j = 1:length(or)
%     chanstr(j).name = chanlabels(app.D{1},labelorder(j));
%     chanstr(j).Color = [179 179 179];
%     suffix{j} = '';
pre=[',''<span>' or{j} '</span>'];
post=[''')'];
    for jj = 1:length(app.plot_cond)
        if any(strcmp(or(j),sig_names{jj}))
            %dojo_style_prefix = strcat('dojo.setAttr(dojo.query("[class=''mwListItem'']")[',num2str(j),'],');
            %win.executeJS([dojo_style_prefix '"after","<span>*</span>")']);
            dojo_style_prefix = strcat('dojo.setAttr(dojo.query("[class=''mwListItem'']")[',num2str(j),'],');
            or{j}=[or{j}];
            
            %txt = [pre '<span>*</span>'')'];
            txt = [pre '<span>*</span>' post];
            pre = [pre '<span>*</span>'];
            %txt = [',''<li data-mw-index="' num2str(j) '" data-mw-tooltiptext="" class="mwListItem">' or{j} '<span>*</span></li>'')'];
            
            win.executeJS([dojo_style_prefix '"innerHTML"',txt]);
            
            
            %dojo_style_prefix = strcat('dojo.style(dojo.query("[class=''mwListItem'']")[',num2str(j),'],');
            
            %win.executeJS([dojo_style_prefix '"color","red")']);
            %suffix{j} = strcat(suffix{j},pre, rgb2Hex( round(app.cc(jj,:).*255) ), '">' ,'*' ,post);
            %suffix{j} = strcat(suffix{j},'*');
        end
    end
end

txt = [',<li data-mw-index=''' j ''' data-mw-tooltiptext="" class="mwListItem"><p>X12</p><p>*</p></li>'];
win.executeJS('dojo.setAttr(dojo.query("[class=''mwListItem'']")[10],''after'',''***'')');
win.executeJS([dojo_style_prefix '"innerHTML"',txt]);

 txt = [pre '<span>*</span>'')'];