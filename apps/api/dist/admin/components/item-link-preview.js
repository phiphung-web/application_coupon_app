"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = ItemLinkPreview;
const jsx_runtime_1 = require("react/jsx-runtime");
const react_1 = require("react");
const design_system_1 = require("@adminjs/design-system");
function ItemLinkPreview(props) {
    const itemId = props.record?.params?.linkItemId;
    const [state, setState] = (0, react_1.useState)({ loading: false });
    (0, react_1.useEffect)(() => {
        if (!itemId) {
            setState({ loading: false, data: undefined });
            return;
        }
        let cancelled = false;
        setState({ loading: true });
        fetch(`/api/products/${itemId}`)
            .then(async (res) => {
            if (!res.ok)
                throw new Error(`Không tải được sản phẩm #${itemId}`);
            return (await res.json());
        })
            .then((data) => {
            if (!cancelled)
                setState({ loading: false, data });
        })
            .catch((err) => {
            if (!cancelled)
                setState({ loading: false, error: err.message });
        });
        return () => {
            cancelled = true;
        };
    }, [itemId]);
    if (!itemId) {
        return ((0, jsx_runtime_1.jsx)(design_system_1.MessageBox, { mt: "lg", message: "Ch\u1ECDn item c\u1EA7n g\u00E1n m\u00E3 \u0111\u1EC3 xem chi ti\u1EBFt." }));
    }
    if (state.loading) {
        return ((0, jsx_runtime_1.jsxs)(design_system_1.Box, { mt: "lg", display: "flex", alignItems: "center", children: [(0, jsx_runtime_1.jsx)(design_system_1.Loader, {}), (0, jsx_runtime_1.jsxs)(design_system_1.Text, { ml: "md", children: ["\u0110ang t\u1EA3i item #", itemId] })] }));
    }
    if (state.error) {
        return ((0, jsx_runtime_1.jsx)(design_system_1.MessageBox, { mt: "lg", variant: "danger", message: state.error ?? "Không tải được thông tin item" }));
    }
    if (!state.data)
        return null;
    const item = state.data;
    return ((0, jsx_runtime_1.jsxs)(design_system_1.Box, { variant: "container", mt: "lg", children: [(0, jsx_runtime_1.jsx)(design_system_1.Label, { children: "S\u1EA3n ph\u1EA9m \u0111ang ch\u1ECDn" }), (0, jsx_runtime_1.jsxs)(design_system_1.Text, { fontWeight: "bold", children: ["#", item.id, " \u00B7 ", item.name] }), (0, jsx_runtime_1.jsxs)(design_system_1.Box, { mt: "sm", children: [item.sourceName ?? item.source?.name ? ((0, jsx_runtime_1.jsxs)(design_system_1.Text, { color: "grey60", children: ["Ngu\u1ED3n: ", item.sourceName ?? item.source?.name] })) : null, item.itemType && ((0, jsx_runtime_1.jsxs)(design_system_1.Text, { color: "grey60", children: ["Lo\u1EA1i: ", item.itemType] })), item.price && (0, jsx_runtime_1.jsxs)(design_system_1.Text, { color: "grey60", children: ["Gi\u00E1: ", item.price] })] })] }));
}
