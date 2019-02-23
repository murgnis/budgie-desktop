gnome = import('gnome')

local_vapis = []
local_vapidir = meson.current_source_dir()

gir = dependency('gobject-introspection-1.0')
gir_dir = gir.get_pkgconfig_variable('girdir')

polkit_gobject_vapi = gnome.generate_vapi('polkit-gobject-1',
    install: false,
    sources: ['polkit-gobject-1-custom.vala', join_paths(gir_dir, 'Polkit-1.0.gir')],
    packages: ['gio-2.0', 'gio-unix-2.0'],
    vapi_dirs: [local_vapidir],
    metadata_dirs: [local_vapidir],
)

polkit_agent_vapi = gnome.generate_vapi('polkit-agent-1',
    install: false,
    sources: ['polkit-agent-1-custom.vala', join_paths(gir_dir, 'PolkitAgent-1.0.gir')],
    packages: ['gio-2.0', 'gio-unix-2.0', polkit_gobject_vapi],
    vapi_dirs: [local_vapidir],
    metadata_dirs: [local_vapidir],
)
