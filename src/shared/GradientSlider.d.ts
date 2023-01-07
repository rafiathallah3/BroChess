interface GradientSlider {
    getColor(percentage: number, ColorKeyPoints: ColorSequenceKeypoint[]): Color3;
    beginSelection(MainFrame: Frame, axis: "X" | "Y", frameToUpdate?: Frame, otherAxis?: "X" | "Y", FrameYangInginDitujukkan?: Frame): void;
    endSelection(): void;
    RGBToColor(ColorShower: Frame, RGBFrame: Frame, together: boolean, onEnterPress: boolean, toUpdateOnChange?: boolean): void;
    enableColorPicker(frame: Frame, axis: "Y" | "X", frameToUpdate: Frame | undefined, otherAxis?: "Y" | "X"): void;
}