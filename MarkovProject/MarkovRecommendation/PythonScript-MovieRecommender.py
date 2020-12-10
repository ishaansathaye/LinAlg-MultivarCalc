# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %%
from IPython import get_ipython

# %% [markdown]
# # Markov Movie Recommender Program
# 

# %%
get_ipython().system('wget -O moviedataset.zip https://s3-api.us-geo.objectstorage.softlayer.net/cf-courses-data/CognitiveClass/ML0101ENv3/labs/moviedataset.zip')
print('unziping ...')
get_ipython().system('unzip -o -j moviedataset.zip')


# %%
import pandas as pd
from math import sqrt
import numpy as np


# %%
#Putting movie data and ratings data from csv into a Pandas DataFrame
moviesDataFrame = pd.read_csv("movies.csv")
ratingsDataFrame = pd.read_csv("ratings.csv")
#Displaying first 5 rows of the movies dataframe
moviesDataFrame.head()


# %%
#Start preproccessing and changing the dataframe to fit the program's specifications
moviesDataFrame['year'] = moviesDataFrame.title.str.extract('(\(\d\d\d\d\))',expand=False)
moviesDataFrame['year'] = moviesDataFrame.year.str.extract('(\d\d\d\d)',expand=False)
moviesDataFrame['title'] = moviesDataFrame.title.str.replace('(\(\d\d\d\d\))', '')
moviesDataFrame['title'] = moviesDataFrame['title'].apply(lambda x: x.strip())
moviesDataFrame.head()
#Removed year from title and made into a separate coulumn


# %%
#Make the Genres into a list in the dataframe
moviesDataFrame["genres"] = moviesDataFrame.genres.str.split('|')
moviesDataFrame.head()


# %%
#Start making the dataframe that relates movies to the genres
#Find all the genres that apply to each movie with a 1 and those that don't with a 0
moviesGenresDataFrame = moviesDataFrame.copy()

for i, r in moviesDataFrame.iterrows():
    for g in r["genres"]:
        moviesGenresDataFrame.at[i, g] = 1

moviesGenresDataFrame = moviesGenresDataFrame.fillna(0)
moviesGenresDataFrame.head()


# %%
#Start the second characteristic of movie recommending: ratings
ratingsDataFrame.head()
#Take out time from the dataframe
ratingsDataFrame = ratingsDataFrame.drop("timestamp", 1)
ratingsDataFrame.head()


# %%
#Take in a user's input of movies that he or she has watched or likes with the ratings of the movies to act as keys
#Add as many movies as the user wants
userInput = [{'title':'Transformers', 'rating':3.5}, {'title':'Toy Story', 'rating':3.5}, {'title':'Jumanji', 'rating':2}, {'title':"Pirates of the Caribbean: On Stranger Tides", 'rating':3.3}, {'title':'Interstellar', 'rating':4.3}]
# userInput = [{'title':'Tuxedo, The', 'rating':3.1}, {'title':'Rush Hour 3', 'rating':3.1}, {'title':'Dragon Blade', 'rating':2.5}, {'title':"Medallion, The", 'rating':3.5}, {'title':'Shanghai Noon', 'rating':3.3}]

#Put the input into a dataframe 
inputMovies = pd.DataFrame(userInput)

#Find movie ID from the movieDataframe that correlates to the User's movies
inputId = moviesDataFrame[moviesDataFrame['title'].isin(inputMovies['title'].tolist())]
inputMovies = pd.merge(inputId, inputMovies)
#Exclude the genres and year from this list
inputMovies = inputMovies.drop('genres', 1).drop('year', 1)
inputMovies


# %%
#Begin creating the transition matrix which will include a combination of ratings and genres for the movies 

#Start with genres
moviesUserDataFrame = moviesGenresDataFrame[moviesGenresDataFrame["movieId"].isin(inputMovies["movieId"].tolist())]
moviesUserDataFrame


# %%
#Clean up to only include the genres for the movies
moviesUserDataFrame = moviesUserDataFrame.reset_index(drop=True)
genreUserDataFrame = moviesUserDataFrame.drop("movieId", 1).drop("title", 1).drop("genres", 1).drop("year", 1)
genreUserDataFrame


# %%
#Start "learning" about the user by combining the ratings and genre values above
profileUserDataFrame = genreUserDataFrame.transpose().dot(inputMovies["rating"])
profileUserDataFrame
#This is the combination of genre/ratings calcuated from the input matrix. It will be used with the transition matrix to create a recommendation


# %%
#Begin to create transition matrix 

#Create genre quantitative table from the MovieLens entire dataset
genreTableDataFrame = moviesGenresDataFrame.set_index(moviesGenresDataFrame["movieId"])
genreTableDataFrame = genreTableDataFrame.drop("movieId", 1).drop("title", 1).drop("genres", 1).drop("year", 1)
genreTableDataFrame.head()


# %%
#Start the recommendation by multiplying the table above with the profile and then take the weighted average
recommendationDataFrame = ((genreTableDataFrame*profileUserDataFrame).sum(axis=1))/(profileUserDataFrame.sum())
recommendationDataFrame.head()


# %%
#Begin to clean the recommendations by sorting them from highest to lowest
recommendationDataFrame = recommendationDataFrame.sort_values(ascending=False)
recommendationDataFrame.head()


# %%
#Finally display the final recommendation table by using the movieId as a key to search the movie dataset
finalRecommendation = moviesDataFrame.loc[moviesDataFrame["movieId"].isin(recommendationDataFrame.head(50).keys())]
finalRecommendation


# %%
#Check to see if extra movie user likes is on the top 50
if "Journey to the Center of the Earth" in finalRecommendation["title"].values:
    print("success")
else:
    print("no")


