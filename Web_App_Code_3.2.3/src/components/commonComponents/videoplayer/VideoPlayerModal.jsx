'use client'
import React, { useState, useEffect } from 'react'
import ReactPlayer from 'react-player'
import { BsFillPlayFill, BsPlayCircle } from 'react-icons/bs'
import VideoPlayer from './HLSPlayer'
import Loader from '../Loader'
import { placeholderImage, translate } from '@/utils/helpers'
import {
  Dialog,
  DialogContent,
  DialogTrigger,
} from "@/components/ui/dialog"
import { FaPlay } from 'react-icons/fa'

const VideoPlayerModal = props => {
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    setIsLoading(true)

    const timer = setTimeout(() => {
      setIsLoading(false)
    }, 2000)

    return () => clearTimeout(timer)
  }, [props.show])

  // Function to check if the URL has an HLS or M3U8 extension
  const isHLSUrl = url => {
    return url?.endsWith('.m3u8')
  }

  // Function to convert YouTube URLs to proper embed format
  const getYoutubeEmbedUrl = (url) => {
    if (!url) return url;
    
    // Handle YouTube Shorts
    if (url.includes('youtube.com/shorts/')) {
      const videoId = url.split('/shorts/')[1]?.split('?')[0];
      if (videoId) {
        return `https://www.youtube.com/embed/${videoId}`;
      }
    }
    
    // Handle regular YouTube URLs
    if (url.includes('youtube.com/watch')) {
      const videoId = new URL(url).searchParams.get('v');
      if (videoId) {
        return `https://www.youtube.com/embed/${videoId}`;
      }
    }
    
    // Handle youtu.be shortened URLs
    if (url.includes('youtu.be/')) {
      const videoId = url.split('youtu.be/')[1]?.split('?')[0];
      if (videoId) {
        return `https://www.youtube.com/embed/${videoId}`;
      }
    }
    
    return url;
  }

  // Check if URL is from YouTube
  const isYoutubeUrl = (url) => {
    return url && (
      url.includes('youtube.com') || 
      url.includes('youtu.be') || 
      url.includes('youtube-nocookie.com')
    );
  }

  // Determine correct video player to use
  const renderVideoPlayer = () => {
    if (isHLSUrl(props.url)) {
      return <VideoPlayer url={props.url} />;
    } 
    
    if (isYoutubeUrl(props.url)) {
      // Use iframe with proper YouTube embed URL
      const embedUrl = getYoutubeEmbedUrl(props.url);
      return (
        <iframe
          className='youtube_player'
          src={embedUrl}
          width='100%'
          height='500px'
          frameBorder='0'
          allowFullScreen
          allow='accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
        />
      );
    }
    
    if (props.type_url === 'video_other' || props.type_url === 'url_other') {
      // For non-YouTube external URLs
      // Note: Some sites still won't allow embedding
      return (
        <iframe
          className='video_other_url'
          allow='autoplay'
          frameBorder='0'
          width='100%'
          allowFullScreen
          src={props.url}
          onError={placeholderImage}
          height='500px'
        />
      );
    }
    
    // Default to ReactPlayer for all other cases
    return <ReactPlayer width='100%' height='500px' url={props.url} controls={true} />;
  }

  return (
    <Dialog className='!border-none relative'>
      {
        props.editNews ?
          <DialogTrigger className={`w-full border borderColor commonRadius px-4 py-2 my-2 flexCenter gap-1`}>
            <span> {translate('previewLbl')}</span>
            <span aria-label="Play video" className='textPrimary cursor-pointer'><BsFillPlayFill /></span>
          </DialogTrigger> :
          <DialogTrigger className={` ${props.styleOne ? 'unset' : 'absolute'} ${props?.styleFive ? 'top-[10%] left-[44%]' : 'top-0 bottom-0 left-0 right-0'} m-auto  h-[44px] w-[44px] flexCenter secondaryBg border-[4px] border-white rounded-full text-white`}>
            {
              props.videoSect ?
                <span aria-label="Play video">
                  <FaPlay className='' />
                </span>
                :
                <span className='textPrimary cursor-pointer'><BsPlayCircle size={40} color='white' /></span>
            }
          </DialogTrigger>
      }
      <DialogContent className='max-h-[600px] max-w-[90%] md:max-w-[60%] !bg-transparent  p-0 overflow-hidden !border !border-transparent videoPlayerModal'>
        {isLoading ? (
          <Loader />
        ) : (
          renderVideoPlayer()
        )}
      </DialogContent>
    </Dialog>
  )
}

export default VideoPlayerModal