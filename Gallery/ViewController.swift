//
//  ViewController.swift
//  Gallery
//
//  Created by Ground 2 on 12/03/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var galleryView: UICollectionView!
    
    @IBOutlet var addImageButton: UIButton!
    
    @IBOutlet var navBarGallery: UINavigationItem!
    
    
    
    
    var imageForCell : UIImage = UIImage(named: "example1")!
    let imagePicker = UIImagePickerController()
    
    
    
    var imageList = [ImageDataEntity]()
    var UIImageList : [UIImage] = []
    var selectedImages : Set<IndexPath> = []
    var mode = false
    
    let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarGallery.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addImage))
        
        fetchCoreData()
        galleryView.dataSource = self
        
        let collectionViewCustomLayout = ColumnFlowLayout(cellsPerRow: 3, minimumInteritemSpacing: 5.0, minimumLineSpacing: 5.0)
        galleryView.collectionViewLayout = collectionViewCustomLayout
        
        let collectionLongpress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressInCollectionView(sender:)))
        galleryView.addGestureRecognizer(collectionLongpress)
        
        let collectionTapPress = UITapGestureRecognizer(target: self, action: #selector(handleTapInCollectionView(sender: )))
        galleryView.addGestureRecognizer(collectionTapPress)
        
    }
    @IBAction func addImageAction(_ sender: Any) {
        
    }
    
    @objc func addImage(){
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func addCoreData(image: UIImage) {
        
        let newData = ImageDataEntity(context: ctx)
        newData.image = image.jpegData(compressionQuality: 0.1)
        imageList.append(newData)
        UIImageList.append(image)
        galleryView.reloadData()
        do {
            try ctx.save()
        } catch {
            print("error-Saving data")
        }
    }
    
    func fetchCoreData() {
        do {
            let items = try ctx.fetch(ImageDataEntity.fetchRequest()) as? [ImageDataEntity]
            imageList.removeAll()
            imageList.append(contentsOf: items!)
            UIImageList.removeAll()
            
            for item in items!{
                UIImageList.append(UIImage(data: item.image!)!)
            }
            
            
        } catch {
            print("error-Fetching data")
        }
        galleryView.reloadData()
    }
    
    func deleteCoreData(indexPath: Int, items: [ImageDataEntity]) {
        let dataToRemove = items[indexPath]
        ctx.delete(dataToRemove)
        do {
            try ctx.save()
        } catch {
            print("error-Deleting data")
        }
    }
    
    @objc private func handleLongPressInCollectionView(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: galleryView)
            if let indexPath = galleryView.indexPathForItem(at: touchPoint) {
               /* let alert = UIAlertController(title: "Delete item", message: "Do you really really want to delete it?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
                    self.deleteCoreData(indexPath: indexPath.item, items: self.imageList)
                    self.imageList.remove(at: indexPath.item)
                    self.UIImageList.remove(at: indexPath.item)
                    self.galleryView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                present(alert, animated: true)
                */
                if(selectedImages.contains(indexPath)){
                    selectedImages.remove(indexPath)
                }
                else{
                    selectedImages.insert(indexPath)
                }
                mode = true
                galleryView.reloadItems(at: [indexPath])
                
                
            }
        }
        if(!selectedImages.isEmpty){
            navBarGallery.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash.fill"), style: .done, target: self, action: #selector(deleteImages))
        }
        else{
            navBarGallery.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addImage))
        }
        
    }
    
    
    @objc private func handleTapInCollectionView(sender: UITapGestureRecognizer) {
        if sender.state != .began && mode {
            let touchPoint = sender.location(in: galleryView)
            if let indexPath = galleryView.indexPathForItem(at: touchPoint) {
                if(selectedImages.contains(indexPath)){
                    selectedImages.remove(indexPath)
                }
                else{
                    selectedImages.insert(indexPath)
                }
                
                galleryView.reloadItems(at: [indexPath])
            }
        }
        
        if(!selectedImages.isEmpty){
            navBarGallery.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash.fill"), style: .done, target: self, action: #selector(deleteImages))
            
        }
        else{
            navBarGallery.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addImage))
            mode = false
        }
        
        
    }
    
    @objc private func deleteImages(){
        let alert = UIAlertController(title: "Delete Images", message: "Do you want to delete selected images?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            let sortedSelectedImages = self.selectedImages.sorted(by: >)
            
            for i in sortedSelectedImages{
                self.deleteCoreData(indexPath: i.item, items: self.imageList)
                self.UIImageList.remove(at: i.item)
            }
            self.selectedImages.removeAll()
            
            self.galleryView.reloadData()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            self.selectedImages.removeAll()
            self.galleryView.reloadData()
            
        }))
        present(alert, animated: true)
        
        
        self.navBarGallery.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(self.addImage))
        mode = false
        
        
        
        
    }
    
    
}



extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UIImageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = galleryView.dequeueReusableCell(withReuseIdentifier: "galleryCell", for: indexPath) as! customGalleryCell
        cell.imageSelectedView.image = UIImageList[indexPath.item]
        
        if(selectedImages.contains(indexPath)){
            cell.blurView.alpha = 0.8
            cell.checkBox.alpha = 1
        }
        else{
            cell.blurView.alpha = 0
            cell.checkBox.alpha = 0
        }
        
        return cell
    }
    
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        imageForCell = image
        
        galleryView.reloadData()
        self.dismiss(animated: true, completion: nil)
        self.addCoreData(image: image)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
    }
}
