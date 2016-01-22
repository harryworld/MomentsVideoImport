//
//  VideoCollectionViewCell.swift
//  Pods
//
//  Created by sohail khan on 19/01/2016.
//
//

import UIKit
import Photos
class VideoCollectionViewCell: UICollectionViewCell {


    
    // MARK:-  Data Members

    var representedAssetIdentifier : String = ""
    // MARK:-  IBOutlets
    @IBOutlet weak var selectionImageView : UIImageView!
    @IBOutlet weak var thumbNailImageView : UIImageView!
    @IBOutlet weak var playerContainerView : UIView!

    @IBOutlet weak var volumeImageView : UIImageView!
    @IBOutlet weak var durationLabel : UILabel!
    @IBOutlet weak var selectUnSelectButton : UIButton!
    @IBOutlet weak var volumeButton : UIButton!
    
    
    var videoPlayer : AVPlayer?
    var avPlayerLayer : AVPlayerLayer?
    var currentRequestID : PHImageRequestID?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
    // resize your layers based on the view's new bounds
        avPlayerLayer?.frame = playerContainerView.bounds
    }
    
    // MARK:-IBAction
    
    @IBAction func volumeButtonPressed(sender : AnyObject) {
        
       // self.videoPlayer?.volume = 1.0
        volumeButton.selected = !volumeButton.selected
        let currentBundle : NSBundle = NSBundle(forClass:object_getClass(self))
        if volumeButton.selected == true {
            self.videoPlayer?.muted = false
            volumeImageView.image = UIImage(named:"sound-playing",inBundle: currentBundle,compatibleWithTraitCollection:nil)
        }else{
            volumeImageView.image = UIImage(named:"sound-pause",inBundle: currentBundle,compatibleWithTraitCollection:nil)
            self.videoPlayer?.muted = true

        }

    }
    @IBAction func selectUnSelectButtonPressed(sender : AnyObject) {
        selectUnSelectButton.selected = !selectUnSelectButton.selected
        let currentBundle : NSBundle = NSBundle(forClass:object_getClass(self))
        if selectUnSelectButton.selected == true {
            selectionImageView.image = UIImage(named:"SectionHeaderChooseHighlight",inBundle: currentBundle,compatibleWithTraitCollection:nil)
        }else{

            selectionImageView.image = UIImage(named:"SectionHeaderChoose",inBundle: currentBundle,compatibleWithTraitCollection:nil)
        }
    }
    
    
    // MARK:-  Public Methods
    
    
    func setVideoData(videoAsset : PHAsset){
        
        durationLabel.text = HNGHelperUtill.stringFromTimeInterval(videoAsset.duration)
        self.representedAssetIdentifier = videoAsset.localIdentifier;

        let chache = HNGImageCachingManager.chache
        /*// Request an image for the asset from the PHCachingImageManager.
        chache.requestImageForAsset(videoAsset, targetSize: self.thumbNailImageView.bounds.size, contentMode:PHImageContentMode.AspectFill, options:nil, resultHandler:{(result:UIImage?,info:Dictionary<NSObject,AnyObject>?)-> Void in
            
            if (self.representedAssetIdentifier == videoAsset.localIdentifier) {
                self.thumbNailImageView.image = result;
                self.thumbNailImageView.layer.cornerRadius = 7.0
                self.thumbNailImageView.clipsToBounds = true
            }
            })*/
        
        if let asset = chache.fetchedAssetsCache?[videoAsset.localIdentifier] {
            self.setMediaPlayer(asset)
        }else{
            
            /*chache.requestPlayerItemForVideo(videoAsset, options:nil, resultHandler:{(avPlayerItem:AVPlayerItem?, info:[NSObject : AnyObject]?) -> Void in
                if let asset = avPlayerItem {
                    chache.fetchedAssetsCache?[videoAsset.localIdentifier] = asset
                    self.setMediaPlayer(asset)
                }
            })*/
            
            
            chache.requestAVAssetForVideo(videoAsset, options:nil, resultHandler:{(avAsset:AVAsset?,audioMix:AVAudioMix?,info:Dictionary<NSObject,AnyObject>?)->Void in
                if let asset = avAsset {
                    chache.fetchedAssetsCache?[videoAsset.localIdentifier] = asset
                    self.setMediaPlayer(asset)
                }
            })
        }

        

    }
    func onCellWillAppearing(){
        playVideo()

    }
    func onCellWillDisAppearing(){
        puseVideo()
    }
    func playVideo(){
        videoPlayer?.play()

    }
    func puseVideo(){
        videoPlayer?.pause()
        if let currReqID = currentRequestID{
            HNGImageCachingManager.chache.cancelImageRequest(currReqID)

        }
    }
    private func setMediaPlayer(asset:AVAsset){
        
        //if (self.representedAssetIdentifier == videoAsset.localIdentifier) {
            
            let playerItem : AVPlayerItem = AVPlayerItem(asset:asset)
            if self.videoPlayer == nil {
                
                self.videoPlayer = AVPlayer(playerItem:playerItem)
                self.avPlayerLayer = AVPlayerLayer(player: self.videoPlayer)
                self.avPlayerLayer?.frame = self.playerContainerView.bounds
                self.playerContainerView.layer.addSublayer(self.avPlayerLayer!)
                self.avPlayerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
                self.playerContainerView.layer.cornerRadius = 7.0
                self.playerContainerView.clipsToBounds = true
                self.setNeedsDisplay()
                
            }else{
                self.videoPlayer?.replaceCurrentItemWithPlayerItem(playerItem)
            }
            self.videoPlayer?.muted = true
            self.videoPlayer?.play()
        //}

    }
    deinit{
        videoPlayer?.pause()
        videoPlayer = nil
    }

}
