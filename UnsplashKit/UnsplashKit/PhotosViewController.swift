// PhotosViewController.swift
//
// Copyright (c) 2016 Camden Fullmer (http://camdenfullmer.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit


class PhotosViewController: UICollectionViewController {
    
    var photos: [Photo] = []
    var client: UnsplashClient?
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInstanceProperties()
        setUpCollectionView()
        loadImages()
    }
    
    // MARK: Private - Setup
    
    private func setUpInstanceProperties() {
        self.client = Unsplash.client
    }
    
    private func setUpCollectionView() {
        self.collectionView!.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.ReuseIdentifier)
        self.collectionView!.backgroundColor = UIColor.white
    }
    
    private func loadImages() {
        self.client!.photos.findPhotos().response({ response, error in
            if let e = error {
                let controller = UIAlertController(title: "Unsplash Error", message: e.description, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                controller.addAction(action)
                self.present(controller, animated: true, completion: nil)
            } else {
                self.photos = response!.photos
                self.collectionView!.reloadData()
            }
        })
        
    
    }
    
    private func sizeForCollectionViewItem() -> CGSize {
        let viewWidth = view.bounds.size.width
        
        let cellWidth = viewWidth
        let cellHeight = CGFloat(200)
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.ReuseIdentifier, for: indexPath as IndexPath) as! ImageCell
        let photo = self.photos[indexPath.row]
        cell.configureCellWithURLString(URLString: photo.urls.small.absoluteString)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return sizeForCollectionViewItem()
        
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
}
