"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = CouponLinkPreview;
const jsx_runtime_1 = require("react/jsx-runtime");
const react_1 = require("react");
const design_system_1 = require("@adminjs/design-system");
function CouponLinkPreview(props) {
    const couponId = props.record?.params?.linkCouponId;
    const [state, setState] = (0, react_1.useState)({ loading: false });
    (0, react_1.useEffect)(() => {
        if (!couponId) {
            setState({ loading: false, data: undefined });
            return;
        }
        let cancelled = false;
        setState({ loading: true });
        fetch(`/api/coupons/${couponId}`)
            .then(async (res) => {
            if (!res.ok) {
                throw new Error(`Không tải được mã #${couponId}`);
            }
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
    }, [couponId]);
    if (!couponId) {
        return ((0, jsx_runtime_1.jsx)(design_system_1.MessageBox, { mt: "lg", message: "Ch\u1ECDn m\u00E3 c\u1EA7n li\u00EAn k\u1EBFt \u0111\u1EC3 xem chi ti\u1EBFt." }));
    }
    if (state.loading) {
        return ((0, jsx_runtime_1.jsxs)(design_system_1.Box, { mt: "lg", display: "flex", alignItems: "center", children: [(0, jsx_runtime_1.jsx)(design_system_1.Loader, {}), (0, jsx_runtime_1.jsxs)(design_system_1.Text, { ml: "md", children: ["\u0110ang t\u1EA3i th\u00F4ng tin m\u00E3 #", couponId] })] }));
    }
    if (state.error) {
        return ((0, jsx_runtime_1.jsx)(design_system_1.MessageBox, { mt: "lg", variant: "danger", message: state.error ?? "Không tải được thông tin mã" }));
    }
    if (!state.data)
        return null;
    const coupon = state.data;
    return ((0, jsx_runtime_1.jsxs)(design_system_1.Box, { variant: "container", mt: "lg", flex: true, flexDirection: "column", "data-testid": "coupon-link-preview", children: [(0, jsx_runtime_1.jsx)(design_system_1.Label, { children: "M\u00E3 \u0111ang ch\u1ECDn" }), (0, jsx_runtime_1.jsxs)(design_system_1.Text, { fontWeight: "bold", children: ["#", coupon.id, " \u00B7 ", coupon.code] }), coupon.description && ((0, jsx_runtime_1.jsx)(design_system_1.Text, { mt: "sm", color: "grey60", children: coupon.description })), (0, jsx_runtime_1.jsxs)(design_system_1.Box, { mt: "sm", children: [coupon.sourceName && ((0, jsx_runtime_1.jsxs)(design_system_1.Text, { color: "grey60", children: ["Ngu\u1ED3n: ", coupon.sourceName] })), coupon.discountType && ((0, jsx_runtime_1.jsxs)(design_system_1.Text, { color: "grey60", children: ["Lo\u1EA1i gi\u1EA3m: ", coupon.discountType, " \u00B7 Gi\u00E1 tr\u1ECB: ", coupon.discountValue] }))] })] }));
}
