namespace PolkitAgent {
  public abstract class Listener : GLib.Object {
    public virtual async bool initiate_authentication(string action_id, string message, string icon_name, Polkit.Details details, string cookie, GLib.List<Polkit.Identity?>? identities, GLib.Cancellable cancellable);
  }
}
