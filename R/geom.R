

roundtrip <- function(x, coll=FALSE) {
	if (coll) {
		p <- methods::new("SpatVectorCollection")
		p@ptr <- x@ptr$bienvenue()
		return(p)
	} else {
		x@ptr <- x@ptr$allerretour()
		return(x)
	}
}

setMethod("is.valid", signature(x="SpatVector"), 
	function(x, messages=FALSE) {
		if (messages) {
			r <- x@ptr$geos_isvalid_msg()
			d <- data.frame(matrix(r, ncol=2, byrow=TRUE))
			d[,1] = d[,1] == "\001"
			colnames(d) <- c("valid", "reason")
			d
		} else {
			x@ptr$geos_isvalid()
		}
	}
)



setMethod("na.omit", signature("SpatVector"), 
	function(object, field=NA, geom=FALSE) {
		if (geom) {
			g <- geom(object)
			g <- g[is.na(g[,"x"]) | is.na(g[,"y"]), 1]
			if (length(g) > 0) {
				object <- object[-g, ]
			}
		}
		if (!is.na(field)) {
			v <- values(object)
			if (field != "") {
				v <- v[, field, drop=FALSE]
			}
			i <- apply(v, 1, function(i) any(is.na(i)))
			if (any(i)) {
				object <- object[!i, ]
			}
		}
		object
	}
)


setMethod("copy", signature("SpatVector"), 
	function(x) {
		x@ptr <- x@ptr$deepcopy() 
		x
	}
)


as.list.svc <- function(x) {
	v <- vect()
	lapply(1:x$size(), 
		function(i) {
			v@ptr <- x$get(i-1)
			v
		})
}



setMethod("split", signature(x="SpatVector"), 
	function(x, f) {
		if (length(f) > 1) {
			x <- copy(x)
			x$f <- f
			f <- "f"
		}
		x <- messages(x@ptr$split(f), "split")
		as.list.svc(x)
	}
)


setMethod("sharedPaths", signature(x="SpatVector"), 
	function(x) {
		x@ptr <- x@ptr$shared_paths()
		messages(x, "sharedPaths")
	}
)

setMethod("cover", signature(x="SpatVector", y="SpatVector"), 
	function(x, y, identity=FALSE) {
		x@ptr <- x@ptr$cover(y@ptr, identity[1])
		messages(x, "cover")
	}
)


setMethod("symdif", signature(x="SpatVector", y="SpatVector"), 
	function(x, y) {
		x@ptr <- x@ptr$symdif(y@ptr)
		messages(x, "symdif")
	}
)

setMethod("erase", signature(x="SpatVector", y="SpatVector"), 
	function(x, y) {
		x@ptr <- x@ptr$erase(y@ptr)
		messages(x, "erase")
	}
)

setMethod("erase", signature(x="SpatVector", y="SpatExtent"), 
	function(x, y) {
		y <- as.polygons(y)
		x@ptr <- x@ptr$erase(y@ptr)
		messages(x, "erase")
	}
)



setMethod("union", signature(x="SpatVector", y="missing"), 
	function(x, y) {
		x@ptr <- x@ptr$union_self()
		messages(x, "union")
	}
)


setMethod("union", signature(x="SpatVector", y="SpatVector"), 
	function(x, y) {
		x@ptr <- x@ptr$union(y@ptr)
		messages(x, "union")
	}
)

setMethod("union", signature(x="SpatVector", y="SpatExtent"), 
	function(x, y) {
		y <- as.vector(y)
		x@ptr <- x@ptr$union(y@ptr)
		messages(x, "union")
	}
)

setMethod("union", signature(x="SpatExtent", y="SpatExtent"), 
	function(x, y) {
		x + y
	}
)


setMethod("intersect", signature(x="SpatVector", y="SpatVector"), 
	function(x, y) {
		x@ptr <- x@ptr$intersect(y@ptr)
		messages(x, "intersect")
	}
)

setMethod("intersect", signature(x="SpatExtent", y="SpatExtent"), 
	function(x, y) {
		x@ptr$intersect(y@ptr)
		x
	}
)

setMethod("intersect", signature(x="SpatVector", y="SpatExtent"), 
	function(x, y) {
		x@ptr <- x@ptr$crop_ext(y@ptr)
		x
	}
)

setMethod("intersect", signature(x="SpatExtent", y="SpatVector"), 
	function(x, y) {
		y <- ext(y)
		x * y
	}
)

#setMethod("intersect", signature(x="SpatRaster", y="SpatRaster"),
#	function(x, y) {
#		a <- crop(x, y)
#		b <- crop(y, x)
#		c(a, b)
#	}
#)

setMethod("buffer", signature(x="SpatVector"), 
	function(x, width, quadsegs=10) {
		x@ptr <- x@ptr$buffer(width, quadsegs)
		messages(x, "buffer")
	}
)


setMethod("crop", signature(x="SpatVector", y="ANY"), 
	function(x, y) {
		if (!inherits(y, "SpatExtent")) {
			y <- try(ext(y), silent=TRUE)
			if (inherits(y, "try-error")) {
				stop("y does not have a SpatExtent")
			}
		}
		x@ptr <- x@ptr$crop_ext(y@ptr)
		messages(x, "crop")
	}
)

setMethod("crop", signature(x="SpatVector", y="SpatVector"), 
	function(x, y) {
		if (length(y) > 1) {
			y <- aggregate(y)
		}
		x@ptr <- x@ptr$crop_vct(y@ptr)
		messages(x, "crop")
	}
)

setMethod("convHull", signature(x="SpatVector"), 
	function(x, by="") {
		x@ptr <- x@ptr$chull(by[1])
		messages(x, "convHull")
	}
)


setMethod("disaggregate", signature(x="SpatVector"), 
	function(x) {
		x@ptr <- x@ptr$disaggregate()
		messages(x, "disaggregate")
	}
)



setMethod("voronoi", signature(x="SpatVector"), 
	function(x, bnd=NULL, tolerance=0, as.lines=FALSE) {
		if (is.null(bnd)) {
			bnd <- vect()
		} else {
			bnd <- as.polygons(ext(bnd))
		}
		x@ptr <- x@ptr$voronoi(bnd@ptr, tolerance, as.lines)
		messages(x, "voronoi")
	}
)


setMethod("delauny", signature(x="SpatVector"), 
	function(x, tolerance=0, as.lines=FALSE) {
		x@ptr <- x@ptr$delauny(tolerance, as.lines)
		messages(x, "delauny")
	}
)


setMethod("flip", signature(x="SpatVector"), 
	function(x, direction="vertical") {
		d <- match.arg(direction, c("vertical", "horizontal")) 
		x@ptr <- x@ptr$flip(d == "vertical")
		messages(x, "flip")
	}
)



setMethod("spin", signature(x="SpatVector"), 
	function(x, angle, x0, y0) { 
		e <- as.vector(ext(x))
		if (missing(x0)) {
			x0 <- mean(e[1:2])
		}
		if (missing(y0)) {
			y0 <- mean(e[3:4])
		}
		angle <- angle[1]
		stopifnot(is.numeric(angle) && !is.nan(angle))
		x@ptr <- x@ptr$rotate(angle, x0[1], y0[1])
		messages(x, "spin")
	}
)
