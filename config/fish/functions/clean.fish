function clean
  sudo paccache -rk1
  sudo paccache -ruk0
  yay -Scc --noconfirm
  duf
end
