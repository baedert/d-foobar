project('cgparser', 'd')


input_files = files([
  'src/main.d',
  'src/app.d',
  'src/mainwindow.d',
  'src/cgreport.d',
  'src/gtkutils.d'
])


gtkd_dep = dependency('gtkd-3')

cgparser = executable(
  'cgparser',
  input_files,
  dependencies: [gtkd_dep],
  d_args: ['-I../src/', # XXX This should become unnecessary with a later meson version
           '-g',
           '-unittest']
)
