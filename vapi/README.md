Refreshing vapis
--------------

To support mutter (and shipped cogl and clutter), something like:

    vapigen --library mutter-clutter-4 mutter-clutter-4-custom.vala /usr/lib/x86_64-linux-gnu/mutter-4/Clutter-4.gir --girdir /usr/lib/x86_64-linux-gnu/mutter-4/ -d . --girdir . --vapidir . --metadatadir . --girdir /usr/lib/x86_64-linux-gnu/mutter-4/

    vapigen --library mutter-cogl-4 mutter-cogl-4-custom.vala /usr/lib/x86_64-linux-gnu/mutter-4/Cogl-4.gir --girdir /usr/lib/x86_64-linux-gnu/mutter-4/ -d . --girdir . --vapidir . --metadatadir . --girdir /usr/lib/x86_64-linux-gnu/mutter-4/

    vapigen --library libmutter-cogl-4 /usr/lib/x86_64-linux-gnu/mutter-4/Cogl-4.gir --girdir /usr/lib/x86_64-linux-gnu/mutter-4/ -d . --girdir . --vapidir . --metadatadir . --girdir /usr/lib/x86_64-linux-gnu/mutter-4/
