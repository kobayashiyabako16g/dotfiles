final: prev: {
  k3d = prev.k3d.override {
    k3sVersion = "1.32.5-k3s1";
  };
}
