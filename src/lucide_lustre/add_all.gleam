import lucide_lustre/internal/config
import lucide_lustre/internal/install_all

pub fn main() {
  let config = config.get_config(False)

  install_all.install_all(config)
}
