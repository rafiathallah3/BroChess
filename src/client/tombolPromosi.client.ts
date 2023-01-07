import { ReplicatedStorage } from "@rbxts/services";

const Event = ReplicatedStorage.remote;

(script.Parent as ImageButton).MouseButton1Click.Connect(() => {
    Event.KirimPromosiCatur.Fire(script.Parent?.Name);
});