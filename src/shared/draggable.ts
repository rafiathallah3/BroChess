import { ContextActionService, UserInputService } from "@rbxts/services";

class Draggable {
    Object: ImageLabel
    DragStarted?: (...args: unknown[]) => void
    DragEnded?: (...args: unknown[]) => void
    Dragged?: (...args: unknown[]) => void
    Dragging: boolean
    InputBegan?: RBXScriptConnection;
    InputEnded?: RBXScriptConnection;
    InputChanged?: RBXScriptConnection;
    InputChanged2?: RBXScriptConnection;

    constructor(Object: ImageLabel) {
        this.Object = Object;
        this.Dragging = false;
    }

    Enable() {
        const object = this.Object;
        let dragInput: InputObject;
        let dragStart: Vector3;
        let startPos: UDim2;
        let preparingToDrag = false;

        const update = (input: InputObject) => {
            const delta = input.Position.sub(dragStart);
            const newPosisi = new UDim2(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y);
            object.Position = newPosisi;

            return newPosisi;
        }

        this.InputBegan = object.InputBegan.Connect((input: InputObject) => {
            if(input.UserInputType === Enum.UserInputType.MouseButton1 || input.UserInputType === Enum.UserInputType.Touch) {
                preparingToDrag = true;
                const pos = UserInputService.GetMouseLocation();
                object.Position = UDim2.fromOffset(pos.X - (object.Parent as Frame).AbsolutePosition.X, pos.Y - (object.Parent as Frame).AbsolutePosition.Y - 35);

                if(this.DragStarted) {
                    this.DragStarted()
                }

                const connection = (input.Changed as RBXScriptSignal<() => void>).Connect(() => {
                    if(input.UserInputState === Enum.UserInputState.End && (this.Dragging || preparingToDrag)) {
                        this.Dragging = false;
                        connection.Disconnect();

                        // if(this.DragEnded && !preparingToDrag) {
                        //     this.DragEnded();
                        // }

                        preparingToDrag = false;
                    }
                });
            }
        });

        this.InputEnded = object.InputEnded.Connect((input) => {
            if(input.UserInputType === Enum.UserInputType.MouseButton1 || input.UserInputType === Enum.UserInputType.Touch) {
                this.Dragging = false;

                if(this.DragEnded) {
                    this.DragEnded();
                }
                
                preparingToDrag = false;
            }
        })

        this.InputChanged = object.InputChanged.Connect((input: InputObject) => {
            if(input.UserInputType === Enum.UserInputType.MouseMovement || input.UserInputType === Enum.UserInputType.Touch) {
                dragInput = input;
            }
        });

        this.InputChanged2 = UserInputService.InputChanged.Connect((input: InputObject) => {
            if(object.Parent === undefined) {
                this.Disable();
                return;
            }

            if(preparingToDrag) {
                preparingToDrag = false;

                this.Dragging = true;
                dragStart = input.Position;
                startPos = object.Position;
            }

            if(input === dragInput && this.Dragging) {
                const newPosisi = update(input);

                if(this.Dragged) {
                    this.Dragged(newPosisi);
                }
            }
        });

        this.Object.GetPropertyChangedSignal("Parent").Connect(() => {
            if(!this.Object.Parent) {
                this.InputChanged2?.Disconnect();
            }
        });
    }

    Disable() {
        this.InputBegan?.Disconnect();
        this.InputChanged?.Disconnect();
        this.InputChanged2?.Disconnect();
        this.InputEnded?.Disconnect();

        if(this.Dragging) {
            this.Dragging = false;
            if(this.DragEnded) {
                this.DragEnded();
            }
        }
    }
}

export = Draggable;