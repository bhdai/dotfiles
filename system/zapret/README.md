# zapret

Bypasses the ISP's SNI filtering for the domains listed in
`system/zapret/zapret-hosts-user.txt`. Needs the `zapret-git` AUR package, which
owns `/opt/zapret`. Deploy the files with:

```bash
sudo install -Dm644 system/zapret/config /opt/zapret/config &&
sudo install -Dm644 system/zapret/zapret-hosts-user.txt /opt/zapret/ipset/zapret-hosts-user.txt &&
sudo install -Dm644 system/zapret/zapret.service /etc/systemd/system/zapret.service &&
sudo systemctl daemon-reload &&
sudo systemctl restart zapret
```

`zapret.service` in `/etc` shadows the packaged unit so zapret no longer waits for
`network-online.target`. When Wi-Fi fails to connect, that wait held up the whole boot
by about a minute, and Quickshell's bar with it. The header of the unit file explains
the chain.

The DPI matches the TLS ClientHello signature (`16 03 01`) only at the start of a
TCP segment, so `--dpi-desync=multisplit --dpi-desync-split-pos=1` splits the
record header after byte 1 and its parser never engages — it never reads the SNI.
`MODE_FILTER=hostlist` keeps this scoped to listed domains; all other traffic is
unmodified. No tunnel, no proxy, real exit IP.

Adding a domain is an edit to the hostlist plus `sudo systemctl restart zapret`.
After a zapret upgrade, `diff system/zapret/config /opt/zapret/config` shows
whether upstream changed the defaults underneath our five `[dotfiles]` edits.
