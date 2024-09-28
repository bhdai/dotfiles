function clean
  echo "Cleaning pacman cache..."
  sudo paccache -rk1
  sudo paccache -ruk0
  echo "Cleaning yay cache..."
  yay -Scc --noconfirm
  echo "Disk usage:"
  duf
  echo "Cleaning completed."
end
