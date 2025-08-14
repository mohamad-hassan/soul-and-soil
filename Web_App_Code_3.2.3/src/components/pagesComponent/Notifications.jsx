import React, { useState, useEffect } from 'react'
import Layout from '../layout/Layout'
import Breadcrumb from '../breadcrumb/Breadcrumb'
import { IoMdThumbsUp } from 'react-icons/io';
import NotificationsSkeleton from '../skeletons/NotificationsSkeleton';
import { useSelector } from 'react-redux';
import { useRouter } from 'next/router';
import { settingsSelector } from '../store/reducers/settingsReducer';
import { currentLanguageSelector } from '../store/reducers/languageReducer';
import { deleteNotificationApi, getNotificationApi } from '@/utils/api/api';
import { NoDataFound, translate } from '@/utils/helpers';
import moment from 'moment-timezone';
import toast from 'react-hot-toast';
import LoadMoreBtn from '../commonComponents/loadermoreBtn/LoadmoreBtn';
import { MdMessage } from 'react-icons/md';
import { setNotificationDataLength, showNotificationState } from '../store/reducers/helperReducer';

const Notifications = () => {

    const settingsData = useSelector(settingsSelector)
    const currentLanguage = useSelector(currentLanguageSelector)

    const systemTimezoneData = settingsData?.data?.system_timezone;

    const [isLoading, setIsLoading] = useState({
        loading: true,
        loadMoreLoading: false
    })

    const [loadMore, setLoadMore] = useState(false)
    const [data, setData] = useState([])
    const [offset, setOffset] = useState(0)
    const [totalData, setTotalData] = useState('')
    const [convertedData, setConvertedData] = useState([]);

    const [currentPage, setCurrentPage] = useState(0)
    const dataPerPage = 6 // number of posts per page


    const handleLoadMore = () => {
        setLoadMore(true)
        setOffset(offset + 1)
    }

    const getNotification = async () => {

        if (offset || dataPerPage) {
            !loadMore ? setIsLoading({ loading: true }) : setIsLoading({ loadMoreLoading: true })
            try {
                const { data } = await getNotificationApi.getNotification({
                    offset: offset * dataPerPage,
                    limit: dataPerPage,
                })

                if (!data?.error) {
                    setTotalData(data.total)
                    setIsLoading({ loading: false })
                    setIsLoading({ loadMoreLoading: false })
                    if (loadMore) {
                        setData((prevData) => [...prevData, ...data?.data])
                    }
                    else {
                        setData(data?.data);
                    }
                }
                else {
                    console.log('error =>', data?.message)
                    setData([])
                    setIsLoading({ loading: false })
                }
            } catch (error) {
                console.log(error)
                setData([])
                setIsLoading({ loading: false })
            }
        }
    };

    useEffect(() => {
        getNotification()
    }, [offset])



    // Function to format the date as "DD/MM/YYYY"
    const formatDate = dateString => {
        return dateString; // Simply return the original date string
    };

    useEffect(() => {
        if (data) {
            const convertedData = data.map(element => {
                // Convert directly from the original date without intermediate formatting
                const convertedTime = moment(element.date).tz(systemTimezoneData).format("DD-MM-YYYY hh:mm:ss A");
                return {
                    ...element,
                    convertedTime
                };
            });
            setConvertedData(convertedData);
        }
    }, [data, systemTimezoneData]);


    useEffect(() => {
    }, [totalData, isLoading, data])


    const handleDeleteComment = async (e, id) => {
        e.preventDefault();
        try {
            await deleteNotificationApi.deleteNotification({
                id: id
            })
            setData((prevData) => prevData.filter((notification) => notification.id !== id));
            setTotalData(totalData - 1)
            toast.success(translate('notificationDeletedSuccessfully'));
        } catch (error) {
            toast.error('Error deleting notification.');
            console.error('Error deleting notification:', error);
        }
    };

    useEffect(() => {
        if (!isLoading.loading && data && data?.length < 1) {
            setNotificationDataLength({ length: 0 })
            showNotificationState({ show: false })
        }
    }, [data,isLoading.loading])


    return (
        <Layout>
            <>
                <Breadcrumb secondElement={translate('personalNotification')} />

                <section className='notifications container mt-8 md:mt-12 pb-12'>
                    <div className='grid grid-cols-1 gap-6'>
                        {
                            isLoading.loading ? [...Array(3)].map((_, index) => (
                                <div key={index}>
                                    <NotificationsSkeleton />
                                </div>))
                                :
                                convertedData && convertedData?.length > 0 ?
                                    convertedData?.map((element) => {
                                        return <div className='flex items-center justify-between flex-wrap gap-y-6 p-4 md:p-6 border borderColor commonBg commonRadius' key={element?.id}>
                                            <div className='flex items-center gap-6'>
                                                <div className='textPrimary'>
                                                    {
                                                        element.type === 'comment_like' ?
                                                            <IoMdThumbsUp size={24} /> :
                                                            <MdMessage size={24} />
                                                    }
                                                </div>
                                                <div className='flex flex-col gap-4'>
                                                    <span className='textPrimary font-[600] text-[18px]'>{element?.message}</span>
                                                    <span className='font-[500] textSecondary'>{element?.convertedTime}</span>
                                                </div>
                                            </div>
                                            <div>
                                                <button className='commonBtn' onClick={e => handleDeleteComment(e, element.id)}>{translate('deleteTxt')}</button>
                                            </div>
                                        </div>
                                    })
                                    :
                                    <div>
                                        {NoDataFound()}
                                    </div>
                        }
                        {totalData > dataPerPage && totalData !== data.length ? (
                            <div className='flexCenter'>
                                <LoadMoreBtn handleLoadMore={handleLoadMore} loadMoreLoading={isLoading.loadMoreLoading} />
                            </div>
                        ) : null}
                    </div>
                </section>
            </>
        </Layout>
    )
}

export default Notifications