import { createSelector,createSlice } from "@reduxjs/toolkit";
import { store } from "../store";

const initialState = {
    isLoginModalOpen: false,
    notificationDataLength: 0,
    showNotification: false
}

export const helperSlice = createSlice({
    name: "helper",
    initialState,
    reducers: {
        setLoginModal: (state, action) => {
            const { openModal } = action.payload.data
            state.isLoginModalOpen = openModal;
        },
        setNotificationData: (state, action) => {
            const { length } = action.payload.data
            state.notificationDataLength = length;
        },
        showNotification: (state, action) => {
            const { show } = action.payload.data
            state.showNotification = show;
        }
    }
});

export const { setLoginModal, setNotificationData, showNotification } = helperSlice.actions;
export default helperSlice.reducer;

export const setLoginModalState = data => {
    store.dispatch(setLoginModal({ data }))
}

export const setNotificationDataLength = data => {
    store.dispatch(setNotificationData({ data }))
}

export const showNotificationState = data => {
    store.dispatch(showNotification({ data }))
}

export const selectHelperState = (state) => state.helper;

export const checkIsLoginModalOpen = createSelector(
    [selectHelperState],
    (helper) => helper.isLoginModalOpen
);

export const notificationDataLength = createSelector(
    [selectHelperState],
    (helper) => helper.notificationDataLength
);

export const checkShowNotification = createSelector(
    [selectHelperState],
    (helper) => helper.showNotification
);