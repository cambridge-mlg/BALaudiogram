function strSubject = getSubjectCode()

strSubject = '';
prompt    = 'Subject code:';
dlg_title = 'Start test';
num_lines = 1;
defAns    = {'test'};
while ( length(strSubject) < 1 )
    strSubject = char(inputdlg(prompt, dlg_title, num_lines, defAns));
end