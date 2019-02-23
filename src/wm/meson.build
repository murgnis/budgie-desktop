custom_target('desktop-file-wm',
    input : 'budgie-wm.desktop.in',
    output : 'budgie-wm.desktop',
    command : [intltool, '--desktop-style', podir, '@INPUT@', '@OUTPUT@'],
    install : true,
    install_dir : join_paths(datadir, 'applications'))


budgie_wm_sources = [
    'background.vala',
    'ibus.vala',
    'keyboard.vala',
    'main.vala',
    'shim.vala',
    'wm.vala',
]

budgie_wm_deps = [
    link_libconfig,
    dep_gnomedesktop,
    dep_gsettings,
    dep_ibus,
    libmutter_vapi,
]

budgie_wm_vala_args =  [
        '--pkg', 'budgie-config',
        '--pkg', 'gdk-3.0',
        '--pkg', 'gdk-pixbuf-2.0',
        '--pkg', 'gio-unix-2.0',
        '--pkg', 'gnome-desktop-3.0',
        '--pkg', 'gsettings-desktop-schemas',
        '--pkg', 'gtk+-3.0',
        '--pkg', 'json-glib-1.0',
        '--pkg', 'ibus-1.0',
        '--pkg', 'x11',
        '--pkg', 'xfixes-4.0',
        '--vapidir', local_vapidir,
        '--vapidir', built_vapidir,
        '--vapidir', dir_libconfig,
]

rpath = ''

if dep_mutter.version().version_compare('>=3.28.0')
    rpath = dep_mutter.get_pkgconfig_variable('typelibdir')
    budgie_wm_vala_args += ['--girdir', rpath]
endif

executable(
    'budgie-wm', budgie_wm_sources,
    dependencies: budgie_wm_deps,
    include_directories: extra_includes,
    install: true,
    vala_args: budgie_wm_vala_args,
    c_args: [
        '-DGNOME_DESKTOP_USE_UNSTABLE_API',
        # Because of usage of custom vapi as dependencies we can't use dependency
        # otherwise we'd get the vapi loaded twice
        run_command('pkg-config', '--cflags', mutter_dep_name).stdout().strip().split(' '),
    ],
    link_args: [
        # Because of usage of custom vapi as dependencies we can't use dependency
        # otherwise we'd get the vapi loaded twice
        run_command('pkg-config', '--libs', mutter_dep_name).stdout().strip().split(' '),
    ],
    install_rpath: rpath,
)

# gschemas
install_data(
    files('com.solus-project.budgie.wm.gschema.xml',
          '20_solus-project.budgie.wm.gschema.override'),
    install_dir: join_paths(datadir, 'glib-2.0', 'schemas'),
)
