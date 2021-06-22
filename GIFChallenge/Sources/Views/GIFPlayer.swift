import UIKit

class GIFPlayer: UIImageView
{
    private var mUrl: URL?
    private var mDeleteGifBtn: UIButton!
    private let mUrlSession: URLSession = .init(configuration: .default, delegate: nil, delegateQueue: nil)
    
    init(url: URL?)
    {
        mUrl = url
        
        super.init(frame: .zero)
        
        setDefaultImage()
        startDownload()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    func updateUrlWith(url: URL?)
    {
        mUrl = url
        startDownload()
    }
}

private extension GIFPlayer
{
    func setDefaultImage()
    {
        let symbolPointSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: symbolPointSize, weight: .semibold)
        let symbolImage = UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: symbolConfig)
        
        isUserInteractionEnabled = true
        backgroundColor = .systemGray4
        tintColor = .systemGray
        contentMode = .scaleAspectFill
        clipsToBounds = true
        image = symbolImage
    }
    
    func startDownload()
    {
        guard let url = mUrl else { return }
        
        let task = mUrlSession.downloadTask(with: url)
        { location, _, error in
            if let error = error
            {
                print(error.localizedDescription)
                return
            }
            
            guard let location = location,
                  let cachedGifFileUrl = FileManager.cacheFile(fileUrl: location, externalUrl: url)
            else
            {
                print("Invalid empty gif file location")
                return
            }
            
            self.setGifWith(location: cachedGifFileUrl)
        }
        
        task.resume()
    }
    
    func setGifWith(location: URL)
    {
        if let imageSource = CGImageSourceCreateWithURL(location as CFURL, nil),
           let gif = UIImage.animatedImageWith(imageSource: imageSource)
        {
            DispatchQueue.main.async
            { [weak self] in
                self?.image = gif
            }
        }
    }
}
