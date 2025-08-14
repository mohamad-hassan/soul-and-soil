'use client'
import React from 'react'
import { FaPlay } from 'react-icons/fa'

const VideoPlayIcon = props => {
    return (
        <>
            <span className={`absolute ${props?.styleFive ? 'top-[10%] left-[44%]' : 'top-0 bottom-0 left-0 right-0'} m-auto z-[5] h-[44px] w-[44px] flexCenter secondaryBg border-[4px] border-white rounded-full text-white`}>
                <span aria-label="Play video">
                    <FaPlay className='' />
                </span>
            </span>
        </>
    )
}

export default VideoPlayIcon
