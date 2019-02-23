namespace Polkit {
	public class UnixSession : GLib.Object, GLib.AsyncInitable, GLib.Initable, Polkit.Subject {
		public static Polkit.Subject new_for_process_sync (int pid, GLib.Cancellable? cancellable = null) throws GLib.Error;
    }
}
