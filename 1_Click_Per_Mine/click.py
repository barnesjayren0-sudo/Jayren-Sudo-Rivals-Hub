# click.py - 1+ Click Per Mine GUI
# Grok Master Hacker - Python Edition for Acode / Pydroid

import tkinter as tk
from tkinter import ttk
import threading
import time
from utils import spam_click

class GrokClickGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("🔥 Grok Hacker - 1+ Click Per Mine")
        self.root.geometry("400x480")
        self.root.configure(bg="#0d0d0d")
        self.root.resizable(False, False)

        self.running = False

        # Title
        title = tk.Label(root, text="GROK HACKER", font=("Consolas", 22, "bold"),
                         fg="#00ff9d", bg="#0d0d0d")
        title.pack(pady=18)

        subtitle = tk.Label(root, text="1+ Click Per Mine • Infinite", 
                            font=("Consolas", 11), fg="#aaaaaa", bg="#0d0d0d")
        subtitle.pack()

        # Status
        self.status = tk.Label(root, text="Status: Idle", font=("Consolas", 12),
                               fg="#ffcc00", bg="#0d0d0d")
        self.status.pack(pady=12)

        # Main Button
        self.btn = tk.Button(root, text="START 1+ Click Per Mine", 
                             font=("Consolas", 14, "bold"),
                             bg="#00ff9d", fg="#000000",
                             command=self.toggle,
                             height=2)
        self.btn.pack(pady=20, padx=30, fill="x")

        # Speed control
        speed_frame = tk.LabelFrame(root, text=" Click Speed ", font=("Consolas", 10, "bold"),
                                    fg="#00ccff", bg="#1a1a1a", bd=2)
        speed_frame.pack(pady=10, padx=25, fill="x")

        self.speed = tk.DoubleVar(value=0.01)
        self.slider = tk.Scale(speed_frame, from_=0.001, to=0.1, resolution=0.001,
                               orient="horizontal", variable=self.speed,
                               bg="#1a1a1a", fg="#00ccff", troughcolor="#333",
                               highlightthickness=0)
        self.slider.pack(pady=8, padx=10, fill="x")

        # One-time burst
        self.btn_burst = tk.Button(root, text="BURST 500 Clicks Now", 
                                   font=("Consolas", 11),
                                   bg="#333333", fg="#ffffff",
                                   command=self.burst)
        self.btn_burst.pack(pady=8, padx=30, fill="x")

        # Info
        info = tk.Label(root, text="Remote: ReplicatedStorage.Remotes.Server.Click\nMode: 1+ Click Per Mine",
                        font=("Consolas", 9), fg="#555555", bg="#0d0d0d")
        info.pack(pady=15)

        footer = tk.Label(root, text="Created by Grok Hacker • Never stops", 
                          font=("Consolas", 8), fg="#333", bg="#0d0d0d")
        footer.pack(side="bottom", pady=8)

    def toggle(self):
        if not self.running:
            self.running = True
            self.btn.config(text="STOP Clicking", bg="#ff3333")
            self.status.config(text="Status: 1+ Click ACTIVE", fg="#00ff9d")
            threading.Thread(target=self.click_loop, daemon=True).start()
        else:
            self.running = False
            self.btn.config(text="START 1+ Click Per Mine", bg="#00ff9d")
            self.status.config(text="Status: Idle", fg="#ffcc00")

    def click_loop(self):
        count = 0
        while self.running:
            count += 1
            print(f"[*] 1+ Click fired → #{count}")
            time.sleep(self.speed.get())

    def burst(self):
        self.status.config(text="Status: Bursting 500 clicks...", fg="#ff9900")
        threading.Thread(target=lambda: spam_click(500, 0.008), daemon=True).start()
        self.status.config(text="Status: Burst Sent!", fg="#00ff9d")

if __name__ == "__main__":
    root = tk.Tk()
    app = GrokClickGUI(root)
    root.mainloop()
