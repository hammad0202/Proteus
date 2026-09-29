from vcdvcd import VCDVCD
import matplotlib.pyplot as plt

vcd = VCDVCD("sim/proteus_core.vcd", store_tvs=True)

signals = [
    "proteus_core_tb.clk",
    "proteus_core_tb.reset",
    "proteus_core_tb.pc[7:0]",
    "proteus_core_tb.instruction[15:0]",
    "proteus_core_tb.opcode[3:0]",
    "proteus_core_tb.r0[31:0]",
    "proteus_core_tb.r1[31:0]",
    "proteus_core_tb.r2[31:0]",
    "proteus_core_tb.r3[31:0]",
]

fig, axes = plt.subplots(len(signals), 1, figsize=(14, 11), sharex=True)

for ax, name in zip(axes, signals):
    sig = vcd[name]
    times = [t / 1000 for t, _ in sig.tv]
    
    values = []
    for _, v in sig.tv:
        if isinstance(v, str) and all(c in "01" for c in v):
            values.append(int(v, 2))
        else:
            values.append(0)

    ax.step(times, values, where="post")
    ax.set_ylabel(name.split(".")[-1].split("[")[0])
    ax.grid(True, alpha=0.3)

axes[-1].set_xlabel("Time (ns)")
fig.suptitle("PROTEUS Processor Core Simulation")
plt.tight_layout()

plt.savefig("sim/proteus_core_waveform.png", dpi=150)
plt.show()
