//
//  MovieListViewController.swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 15/05/2023.
//
import Combine
import UIKit

class MovieListViewController: UIViewController, Injectable {
    
    // MARK: - IBOutlets
    @IBOutlet var searchContainerView: UIView!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet private var collectionView: UICollectionView!
    
    // MARK: - Local Variables
    private var viewModel: MovieListViewModel!
    private var cancellables: Set<AnyCancellable> = []
    private var originalContentOffset: CGPoint = .zero
    private var debounceTimer: Timer?

    var isSearching = false {
        didSet {
            restoreCollectionViewLayout()
        }
    }

    // MARK: - Dependency Injection
    struct Dependency {
        let service: MovieService
        let router: MovieListRouter
    }
    
    func inject(dependency: Dependency) {
        let movieService = dependency.service
        let router = MovieListRouter(viewController: self)
        viewModel = MovieListViewModel(movieService: movieService, router: router)
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupViews()
        viewModel.fetchPopularMovies()
        
        viewModel.$movies.sink(receiveValue: { [weak self] _ in
            self?.collectionView.reloadData()
        }).store(in: &cancellables)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Custom Functions
    private func bindViewModel() {
        viewModel.$movies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self, let error = error else { return }
                self.displayError(message: error.localizedDescription)
            }
            .store(in: &cancellables)
    }
    
    fileprivate func restoreCollectionViewLayout() {
        if isSearching {
            let searchLayout = UICollectionViewFlowLayout()
            searchLayout.scrollDirection = .vertical
            
            // Calculate the item width based on the available width and desired number of items per row
            let availableWidth = collectionView.bounds.width
            let numberOfItemsPerRow: CGFloat = 2
            let cellWidth = (availableWidth - (searchLayout.minimumInteritemSpacing * (numberOfItemsPerRow - 1))) / numberOfItemsPerRow
            
            // Set the item size in the layout
            searchLayout.itemSize = CGSize(width: cellWidth, height: 150) // Adjust the cellHeight to your desired value
            
            collectionView.collectionViewLayout = searchLayout
        } else {
            let layout = TiltedFlowLayout(itemSizeRatio: 0.85)
            collectionView.collectionViewLayout = layout
            collectionView.contentOffset = originalContentOffset
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let movieListCellNib = UINib(nibName: Constants.movieListCell, bundle: nil)
        collectionView.register(movieListCellNib, forCellWithReuseIdentifier: Constants.movieListCell)
        
        restoreCollectionViewLayout()
    }
    
    func displayError(message: String) {
        let alert = UIAlertController(title: Constants.errorTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Constants.okActionTitle, style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func updateMovieFavoriteStatus(at index: Int, isFavorited: Bool) {
        let indexPath = IndexPath(item: index, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? MovieListCell {
            let heartImage = isFavorited ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
            cell.heartButton.setImage(heartImage, for: .normal)
        }
    }
    
    private func setupViews() {
        setupSearchContainerView()
        setupCollectionView()
    }
    
    private func setupSearchContainerView() {
        searchContainerView.applyCornerRadius(5)
        searchContainerView.backgroundColor = #colorLiteral(red: 0.125, green: 0.1289999932, blue: 0.175999999, alpha: 1)
        searchTextField.layer.borderWidth = 0
        searchContainerView.layer.borderColor = #colorLiteral(red: 0.09803921569, green: 0.1019607843, blue: 0.1450980392, alpha: 1)
        searchContainerView.layer.borderWidth = 0.5
        configureClearButtonAppearance()
        searchTextField.delegate = self
    }
    
    private func configureClearButtonAppearance() {
        if let clearButton = searchTextField.value(forKey: "_clearButton") as? UIButton {
            clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            clearButton.tintColor = .white // Set your desired color
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MovieListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in _: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        viewModel.movies.count
    }
    
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.showMovieDetail(for: viewModel.movies[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.movieListCell, for: indexPath) as? MovieListCell else {
            return UICollectionViewCell()
        }
        let movie = viewModel.movies[indexPath.item]
        cell.configure(with: movie, isSearching: self.isSearching) { [weak self] in
            let isFavorited = self?.viewModel.toggleFavorite(at: indexPath.row)
            self?.updateMovieFavoriteStatus(at: indexPath.row, isFavorited: isFavorited!)
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let availableWidth = view.bounds.width - layout.sectionInset.left - layout.sectionInset.right
        let cellWidth = (availableWidth - layout.minimumInteritemSpacing * (CGFloat(Constants.columnsCount) - 1)) / CGFloat(Constants.columnsCount)
        
        let offsetX = scrollView.contentOffset.x
        let contentWidth = scrollView.contentSize.width
        let width = scrollView.frame.size.width
        
        let cellWidthIncludingSpacing = cellWidth + layout.minimumInteritemSpacing
        let preloadOffset = cellWidthIncludingSpacing * 3 // preload when 2 cells are left
        
        if offsetX > contentWidth - width - preloadOffset {
            if isSearching, let text = searchTextField.text, text.count > 0 {
                viewModel.searchMovies(with: searchTextField.text ?? "")
            } else {
                viewModel.fetchPopularMovies()
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension MovieListViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_: UITextField) -> Bool {
        true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString text: String) -> Bool {
        guard let currentText = textField.text, let textRange = Range(range, in: currentText) else {
            return true
        }
        
        let updatedText = currentText.replacingCharacters(in: textRange, with: text)
        
        /// Invalidate the debounce timer
        debounceTimer?.invalidate()
        if text.trim.isEmpty {
            // Start a new debounce timer after a delay of 0.5 seconds
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
                // Perform the search with the updated text
                self?.handleSearch(updatedText)
            }
            
        } else {
            handleSearch(updatedText)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Handle search when editing is done
        if let text = textField.text {
            handleSearch(text)
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // Clear the search and restore original state
        textField.text = nil
        handleSearch("")
        return true
    }
    
    private func handleSearch(_ searchText: String) {
        // Store the original content offset before performing the search
        originalContentOffset = collectionView.contentOffset
        
        // Perform search API call
        if searchText.isEmpty {
            // Restore original state
            viewModel.movies = viewModel.originalMovies
            UIView.animate(withDuration: 0.3) {
                self.collectionView.contentOffset = self.originalContentOffset
            }
            isSearching = false
        } else {
            if isSearching.isFalse {
                viewModel.originalMovies = viewModel.movies
            }
            // Call the search function in the view model
            viewModel.searchMovies(with: searchText)
            isSearching = true
        }
        
        // Scroll back to the previous position
    }
}

enum Constants {
    static let movieListCell = "MovieListCell"
    static let columnsCount = 2
    static let contentHorizontalPadding: CGFloat = 5
    static let contentVerticalPadding: CGFloat = 5
    static let cellsHorizontalPadding: CGFloat = 10
    static let cellsVerticalPadding: CGFloat = 10
    static let errorTitle = "Error"
    static let okActionTitle = "OK"
}

struct Section: Hashable {
    let title: String
    let items: [Item]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: Section, rhs: Section) -> Bool {
        lhs.title == rhs.title
    }
}

struct Item: Hashable {
    let identifier: String
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
