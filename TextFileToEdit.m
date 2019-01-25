function TextFileToEdit( filename, edit )

strThe = fileread( filename );
set(edit,'String',strThe);