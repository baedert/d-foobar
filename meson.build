project('cgparser', 'd')


input_files = files([
  'src/main.d',
  'src/app.d',
  'src/mainwindow.d',
  'src/mainwidget.d',
  'src/cgreport.d',
  'src/gtkutils.d',
  'src/ipage.d',
  'src/account.d',
  'src/twitter.d',
  'src/avatarwidget.d',
  'src/hometimeline.d',
  'src/userstream.d',
  'src/rest.d',
])


gtkd_dep = dependency('gtkd-3')

cgparser = executable(
  'cgparser',
  input_files,
  dependencies: [gtkd_dep],
  d_args: ['-I../src/', # XXX This should become unnecessary with a later meson version
           '-J../src/',
           '-gc',
           '-d-debug',
           '-unittest']
)
