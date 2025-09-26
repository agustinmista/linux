{
  qemu,
  initramfs,
  linux,
  writeShellApplication,
}:
writeShellApplication {
  name = "qemu";
  runtimeInputs = [
    qemu
    initramfs
    linux
  ];
  text = ''
    qemu-system-x86_64 \
      -kernel ${linux}/boot/bzImage \
      -initrd ${initramfs} \
      -nographic \
      -serial mon:stdio \
      -append "console=ttyS0,115200 quiet" \
      -enable-kvm
  '';
}
